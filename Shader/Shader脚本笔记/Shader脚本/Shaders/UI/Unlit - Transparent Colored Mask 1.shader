Shader "Hidden/Unlit/Transparent Colored Mask 1"
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
	float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
	float2 _ClipArgs0 = float2(1000.0, 1000.0);
			
	struct VS_OUTPUT
    {
        float4 pos : POSITION;
        float2 uv : Texcoord0;
        float2 uv1 : Texcoord1;
        fixed4 clr : COLOR;
		float2 worldPos : TEXCOORD2;
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
        output.worldPos = input.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
        output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.uv1 = TRANSFORM_TEX(input.texcoord1, _MainTex);
        output.clr = input.color;

        return output;
	}
	
	float4 PS(VS_OUTPUT input) : COLOR
	{
		float2 factor = (float2(1.0, 1.0) - abs(input.worldPos)) * _ClipArgs0;
		float4 result = tex2D(_MainTex, input.uv);
		result *= input.clr;
		result.a *= tex2D(_MaskTex, input.uv1).r * input.clr.a;
		result.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);

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

