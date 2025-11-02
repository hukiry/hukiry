Shader "Hidden/PreviewRenderTexture"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;

    struct appdata_t
    {
        float4 vertex : POSITION;
        half4 color : COLOR;
        float2 texcoord : TEXCOORD0;
    };

    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
        half4 color : COLOR;
    };

    VS_OUTPUT MainVS(appdata_t input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.color = input.color;
        return output;
    }

    float4 MainPS_AlphaBlend(VS_OUTPUT input) : COLOR
    {
        float4 color = tex2D(_MainTex, input.v2Texcoord) * input.color;
        if (color.a == 0)
            color = float4(0, 0, 0, 0);
        return color;
    }

    float4 MainPS_Additive(VS_OUTPUT input) : COLOR
    {
        float4 color = tex2D(_MainTex, input.v2Texcoord) * input.color;
        if (color.a > 0.00001)
            color = float4(0, 0, 0, 0);

        color.a = (0.22*color.r + 0.707*color.g + 0.071*color.b) * input.color.a;
        color.a = input.color.a;
        
        return color;
    }
    ENDCG

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog{ Mode Off }
            Offset -1, -1
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  MainPS_AlphaBlend
            #pragma target 2.0
            ENDCG
        }

        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog{ Mode Off }
            Offset -1, -1
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  MainPS_Additive
            #pragma target 2.0
            ENDCG
        }
    }
}
