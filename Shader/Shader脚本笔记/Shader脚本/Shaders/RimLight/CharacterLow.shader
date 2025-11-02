Shader "YueChuan/Character/CharacterLow" 
{
    Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Base (RGB)", 2D) = "White" {}
		_GrayAmount ("Gray Amount", Float) = 0.0
		_EmissionAmount ("Emissive Amount", Float) = 1.0
		[HideInInspector]_AdditionColor ("Addition Color", Color) = (1.0,1.0,1.0,1.0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "CharacterInfo.cginc"
   
    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;
    float _Outline;
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
        fixed4 v4RimColor : TEXCOORD1;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.v4RimColor = _RimColor * _Attenuation; 
        return output;
    }

    float4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
        fixed4 v4Color = CharacterColor(v4RGBColor,input.v4RimColor);	
        v4Color.a = 1;
        return v4Color;
    }
    
    void MainOCVS(appdata_base input,out float4 v4Position : SV_POSITION)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
    }

	fixed4 MainOCPS(VS_OUTPUT input) : COLOR 
	{
		return float4(0.5f, 1.0f, 0.9f, 0.3f);
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
		Tags {"RenderType"="Opaque" "Queue"="Geometry+3" }
		LOD 200

	    Pass 
        {
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
