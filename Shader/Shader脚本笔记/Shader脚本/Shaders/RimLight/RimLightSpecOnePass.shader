Shader "YueChuan/RimLight/RimLightSpecOnePass" 
{
    Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor ("Spec Color", Color) = (1.0,1.0,1.0,1.0)
		_Emission ("Emissive Color", Color) = (0.0,0.0,0.0,0.0)
		_Shininess ("Shininess", Range(0.0,10.0)) = 0.7
		_MainTex ("Base (RGB)", 2D) = "White" {}
		_RimColor ("Edge Color", Color) = (1.0,1.0,1.0,1.0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "CharacterInfo.cginc"
   
    uniform sampler2D _MainTex;
           
    uniform half _RimLightAmount;
    uniform half4 _MainTex_ST;
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
        fixed4 v4LightColor : TEXCOORD1;
        fixed4 v4RimColor : TEXCOORD2;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        half3 v3LightColor =  ShadeLights(input.vertex,input.normal);
        output.v4LightColor = fixed4(v3LightColor.rgb,1.0);
       
        float4 v4WPos = mul(_Object2World, input.vertex);
        float3 v3WNormal = normalize(mul((float3x3)_Object2World, input.normal));
        float3 vEyeDir = normalize(_WorldSpaceCameraPos.xyz - v4WPos.xyz);
        output.v4RimColor = RimLight(vEyeDir,v3WNormal,0.5,_RimColor) * _RimLightAmount;
        return output;
    }

    fixed4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
		fixed4 v4FinialColor = fixed4(0,0,0,0);
		v4FinialColor = v4RGBColor * input.v4LightColor + input.v4RimColor;		
        v4FinialColor.a = v4RGBColor.a;
        return v4FinialColor;
    }
    ENDCG

    SubShader
	{
		Tags {"RenderType"="Opaque" "Queue"="Geometry+400"}
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
