Shader "YueChuan/Others/AlphaBlendColor_NoZTest"
{
	Properties 
	{
		_TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01, 3)) = 1
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	float4 _TintColor;
	
	struct VS_OUTPUT
    {
        float4 pos : SV_POSITION;
        float2 uv : Texcoord0;
        fixed4 clr : COLOR;
    };
    
	VS_OUTPUT VS(appdata_full input)
	{
		VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.uv = input.texcoord.xy;
        output.clr = input.color;

        return output;
	}
	
	float4 PS(VS_OUTPUT input) : COLOR
	{
		float4 result = tex2D(_MainTex, input.uv);
		result *= (2.0 * input.clr) * _TintColor;
		return result;
	}
    
    ENDCG
	
	SubShader 
	{
		Tags { "Queue"="Transparent"  "IgnoreProjector"="True" } 
		Pass 
        {
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			ZTest always
			ZWrite off
			Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }

            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS
            #pragma target 2.0
           
            ENDCG
        }
	}
}
