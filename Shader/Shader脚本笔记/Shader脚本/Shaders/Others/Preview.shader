Shader "YueChuan/Others/Preview"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_LumThreshhold ("Lumia Threshhold", Range(0, 1)) = 0.1
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
            
    sampler2D _MainTex;
    float _LumThreshhold;
    
    struct VS_OUTPUT
    {
        float4 pos : SV_POSITION;
        float2 uv : Texcoord0;
    };
    
    VS_OUTPUT VS(appdata_base input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.uv = input.texcoord;

        return output;
    }

    float4 PS(VS_OUTPUT input) : COLOR 
    {
        float4 color = tex2D(_MainTex, input.uv);
        if (color.g < _LumThreshhold)
        	color.a = 0;
        return saturate(color);
    }
    
    ENDCG
	
	SubShader 
	{
		LOD 200
		Pass 
        {
        	Blend SrcAlpha OneMinusSrcAlpha
        
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS
            #pragma target 2.0
           
            ENDCG
        }
	}
}
