Shader "Unlit/Transparent Colored Mask"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Mask (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	sampler2D _MaskTex;
	float4 _MainTex_ST;	
	
	struct VS_OUTPUT
    {
        float4 pos : POSITION;
        float2 uv : Texcoord0;
        float2 uv1 : Texcoord1;
        fixed4 clr : COLOR;
    };
    
    struct appdata
    {
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD0;
		float4 texcoord1 : TEXCOORD1;
		float4 color : COLOR;
    };
    
	VS_OUTPUT VS(appdata input)
	{
		VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.uv1 = TRANSFORM_TEX(input.texcoord1, _MainTex);
        output.clr = input.color;

        return output;
	}
	
	float4 PS(VS_OUTPUT input) : COLOR
	{
		float4 result = tex2D(_MainTex, input.uv);
		result *= input.clr;
		result.a *= tex2D(_MaskTex, input.uv1).r * input.clr.a;
		return result;
	}
    
    ENDCG
	
	SubShader 
	{
		Pass 
        {
        	Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS
            #pragma target 2.0
           
            ENDCG
        }
	}
}

