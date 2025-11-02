Shader "YueChuan/Character/CharacterHigh" 
{
    Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Base (RGB)", 2D) = "White" {}
        _Flash("Flash (RGB)", 2D) = "black" {}
        _FlashColor("Flash Color", Color) = (1.0,1.0,1.0,1.0)
        _FlashSpeed("Flash Speed", Vector) = (4, 0, 0, 4)
        _FlashIntensity("Flash Intensity", Float) = 2.0
		_GrayAmount ("Gray Amount", Float) = 0.0
		_EmissionAmount ("Emissive Amount", Float) = 1.0
		_Stencil("Stencil ID", Float) = 0.0
		_SideColor("SideColor", Color) = (1.0,1.0,1.0,1.0)
        _Factor("Factor",range(0,1)) = 0.5
        _Outline("Thick of Outline",Float) = 0.03
        //_LineColor("LineColor", Color) = (0.0,0.0,0.0,1.0)
		[HideInInspector]_AdditionColor ("Addition Color", Color) = (1.0,1.0,1.0,1.0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "CharacterInfo.cginc"
   
    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;
    uniform half _IsRimLight;
    float _Outline;
    float _Factor;
    sampler2D _Flash;
    fixed4 _FlashColor;
    fixed4 _FlashSpeed;
    half _FlashIntensity;
    //half4 _LineColor;
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
        fixed4 v4RimColor : TEXCOORD1;
        float3 v3NormalViewSpace : TEXCOORD2;
        float3 v3PosViewSpace : TEXCOORD3;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.v4RimColor = 0;

        float4 v4WPos = mul(_Object2World, input.vertex);
        float3 v3WNormal = normalize(mul((float3x3)_Object2World, input.normal));
        float3 vEyeDir = normalize(_WorldSpaceCameraPos.xyz - v4WPos.xyz);

        if (_IsRimLight)
        {
            output.v4RimColor = RimLight(vEyeDir,v3WNormal,0.3,_RimColor) * _Attenuation; 
            //output.v4RimColor = fixed4(_Attenuation * _RimColor.rgb,1.0);
        }

        float3 v3ViewPos = mul(UNITY_MATRIX_MV, input.vertex);
        float3 v3ViewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, input.normal);
        output.v3NormalViewSpace = v3ViewNormal;

        output.v3PosViewSpace = mul((float3x3)UNITY_MATRIX_IT_MV, input.vertex.xyz);

        return output;
    }

    fixed4 FlashLight(VS_OUTPUT input, half mask)
    {
        half2 flashUV = fmod(input.v2Texcoord + (_FlashSpeed.xy + _FlashSpeed.zw) * _Time.x, 1.0);
        fixed4 flash = tex2D(_Flash, input.v2Texcoord + flashUV);

        flash = flash * flash * _FlashColor * mask.r * _FlashIntensity;
        return flash;
    }

    fixed4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
        fixed3 viewDir = normalize(input.v3PosViewSpace);
        fixed3 lightDir = normalize(float3(-0.3, 0.2, 1));
        fixed4 light = SideLight(viewDir, input.v3NormalViewSpace, lightDir);

        fixed4 v4Color = CharacterColor(v4RGBColor, input.v4RimColor) * light + FlashLight(input, v4RGBColor.a);
        v4Color.a = 1;
		//v4Color.rgb = lerp(v4Color.rgb, float3(0, 0.5, 0), input.v4SideLine);

        return v4Color;
    }
    
    VS_OUTPUT MainOCVS(appdata_base input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);

		float4 v4WPos = mul(_Object2World, input.vertex);
        half3 v3WNormal = mul((float3x3)_Object2World, input.normal);
        half3 vEyeDir = normalize(_WorldSpaceCameraPos.xyz - v4WPos.xyz);
        output.v4RimColor = _RimLight(vEyeDir,v3WNormal, 1); 

		return output;
    }

	fixed4 MainOCPS(VS_OUTPUT input) : COLOR
	{
		//fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
		fixed4 result = fixed4(0.5, 1.0, 0.9,0.5);
	    //fixed4 result = dot(v4RGBColor.rgb,fixed3(0.299,0.587,0.114));
		result.a = input.v4RimColor.r;
		return  result;
	}

    VS_OUTPUT DrawLineVS(appdata_full v)
    {
        VS_OUTPUT o;
        /*float3 dir = normalize(v.vertex.xyz);
        float3 dir2 = v.normal;
        float D = dot(dir, dir2);
        dir = dir*sign(D);
        dir = dir*_Factor + dir2*(1 - _Factor);*/
        float3 dir = v.normal;
        v.vertex.xyz += dir*_Outline;
        o.v4Position = mul(UNITY_MATRIX_MVP, v.vertex);
        return o;
    }

    float4 DrawLinePS(VS_OUTPUT i) :COLOR
    {
        float4 c = _Color / 4.5;
        c.a = 1;
        return c;
    }
    ENDCG

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+3" }
        LOD 250

        //Pass
        //{
        //	Cull Back 
        //	ZTest Greater
        //	ZWrite off
        //	Blend SrcAlpha OneMinusSrcAlpha

        //	CGPROGRAM
        //          #pragma vertex MainOCVS
        //          #pragma fragment  MainOCPS
        //          #pragma target 2.0
        //	ENDCG
        //}

        Pass
        {
            Cull Front
            ZWrite On
            CGPROGRAM
#pragma vertex DrawLineVS
#pragma fragment DrawLinePS
#pragma target 2.0
            ENDCG
        }

        Pass
        {
            //Stencil
            //   {
            // //   Ref 3
            //	Ref[_Stencil]
            //    Comp always
            //    Pass replace
            //   	}
            ZTest Less
            Cull Back

            CGPROGRAM
#pragma vertex MainVS
#pragma fragment  MainPS
#pragma target 2.0
            ENDCG
        }
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+3" }
        LOD 200

        Pass
        {
            //Stencil
            //   {
            // //   Ref 3
            //	Ref[_Stencil]
            //    Comp always
            //    Pass replace
            //   	}
            ZTest Less
            Cull Back

            CGPROGRAM
#pragma vertex MainVS
#pragma fragment  MainPS
#pragma target 2.0
            ENDCG
        }
    }
}
