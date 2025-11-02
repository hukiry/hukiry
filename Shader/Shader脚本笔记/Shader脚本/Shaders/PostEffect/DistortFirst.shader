Shader "YueChuan/PostEffect/DistortFirst"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _NormalTex("Normal Texture", 2D) = "white" {}
        _DistortMultiply("Distort", Float) = 0.1
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    half4 _MainTex_ST;

    sampler2D _NormalTex;
    float _DistortMultiply;

    struct VS_OUTPUT
    {
        float4 pos : SV_POSITION;
        float2 uv : Texcoord0;
        float3 n : Texcoord1;
    };

    VS_OUTPUT VS(appdata_full input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

        float4 normalProj = mul(UNITY_MATRIX_MVP, float4(input.normal, 1));
        normalProj /= normalProj.w;
        output.n = normalProj.xyz;

        return output;
    }

    float4 PS(VS_OUTPUT input) : COLOR
    {
        fixed3 normal = UnpackNormal(tex2D(_NormalTex, input.uv));
        fixed3 vertexNormal = input.n;
        fixed3 distort = normalize(vertexNormal + normal * _DistortMultiply);

        // 将扰动值，缩放到0.1 - 1， 0表示无扰动
        distort.xy = (distort.xy + 1) * 0.5; // 0 - 1
        distort.xy = distort.xy * 0.9 + 0.1;

        return float4(distort.xy, 0, 1);
    }

    ENDCG

    SubShader
    {
        Lighting Off ZWrite Off

        Tags{ "RenderType"="Transparent" "Queue"="Transparent-1" "Distort"="True" }
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
