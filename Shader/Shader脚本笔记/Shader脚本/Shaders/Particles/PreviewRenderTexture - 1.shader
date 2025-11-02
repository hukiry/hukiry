Shader "Hidden/PreviewRenderTexture 1"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;

    float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
    float2 _ClipArgs0 = float2(1000.0, 1000.0);

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
        float2 worldPos : TEXCOORD1;
        half4 color : COLOR;
    };

    VS_OUTPUT MainVS(appdata_t input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.worldPos = input.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
        output.color = input.color;

        return output;
    }

    float4 MainPS_AlphaBlend(VS_OUTPUT input) : COLOR
    {
        float4 color = tex2D(_MainTex, input.v2Texcoord) * input.color;
        if (color.a == 0)
            color = float4(0, 0, 0, 0);

        float2 factor = (float2(1.0, 1.0) - abs(input.worldPos)) * _ClipArgs0;
        color.a *= clamp(min(factor.x, factor.y), 0.0, 1.0);

        return color;
    }

    float4 MainPS_Additive(VS_OUTPUT input) : COLOR
    {
        float4 color = tex2D(_MainTex, input.v2Texcoord) * input.color;
        if (color.a > 0.00001)
            color = float4(0, 0, 0, 0);

        color.a = 0.22*color.r + 0.707*color.g + 0.071*color.b;
        color.a = input.color.a;

        float2 factor = (float2(1.0, 1.0) - abs(input.worldPos)) * _ClipArgs0;
        float fade = clamp(min(factor.x, factor.y), 0.0, 1.0);
        color = lerp(float4(0, 0, 0, 0), color, fade);
        
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
