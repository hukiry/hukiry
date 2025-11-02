Shader "YueChuan/PostEffect/DistortBlend"
{
	Properties 
	{
        _MainTex("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
# include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _DistortTexture;

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
        float4 distort = tex2D(_DistortTexture, input.uv);   

        float2 xy = float2(0, 0);

        if (distort.x > 0.1)
            xy.x = (distort.x - 0.1) / 0.9 * 2.0 - 1;
        if (distort.y > 0.1)
            xy.y = (distort.y - 0.1) / 0.9 * 2.0 - 1;

        //return tex2D(_MainTex, input.uv);
        return tex2D(_MainTex, input.uv + xy * 0.08f);
    }
    
    ENDCG

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

		Pass
        {
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS
            #pragma target 2.0

            ENDCG
        }
    }
}

