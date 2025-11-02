Shader "Custom/Unlit - PureColor"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    CGINCLUDE
    #include "UnityCG.cginc"

    struct VS_OUTPUT
    {
        float4 pos : POSITION;
        fixed4 clr : COLOR;
    };

    struct appdata
    {
        float4 vertex : POSITION;
        float4 color : COLOR;
    };

    VS_OUTPUT VS(appdata input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.clr = input.color;

        return output;
    }

    float4 PS(VS_OUTPUT input) : COLOR
    {
        float4 result = input.clr;
        result.a = 0.5;
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
            Fog{ Mode Off }
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
