Shader "Custom/PreviewAdditiveMobile"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
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
        float4 color = tex2D(_MainTex, input.uv);
        color = color * input.clr * color.a;
        color.a = 0;

        return color;
    }

    ENDCG

    SubShader
    {
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" }
        Pass
        {
            //BlendOp Max
            //Blend SrcAlpha DstAlpha
            Blend One One
            //ZTest always
            ZWrite off
            ColorMask RGBA
            Cull Off Lighting Off ZWrite Off Fog{ Color(0,0,0,0) }

            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS
            #pragma target 2.0

            ENDCG
        }
    }
}
