Shader "YueChuan/Others/SkillRange"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "black" {}
		_Angle ("Angle", Float) = 3.14
		_EdgeColor("Edge Color", Color) = (0.28, 0.48, 0.48, 1)
		_IsCircle("IsCircle", Int) = 0
		_Color("Color", Color) = (1, 1, 1, 1)
		_ColorMultiplier("ColorMultiplier", Float) = 1.0
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _Angle;
	float4 _EdgeColor;
	int _IsCircle;
	float4 _Color;
	float _ColorMultiplier;
    
    struct VS_OUTPUT
    {
        float4 pos : POSITION;
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
		float2 dir = normalize(input.uv - float2(0.5, 0.5));

		float4 color = tex2D(_MainTex, input.uv);

		if (_IsCircle == 0)
		{
			float3 edgeAdd = float3(0, 0, 0);
			float angleThreshhold = cos(0.017*2);
			float cosToEdge = 0;
			//float alpha = 1.0f;
			if (dir.x < 0)
			{
				float2 edgeLeft = normalize(float2(-sin(_Angle*0.5f), cos(_Angle*0.5f)));
				cosToEdge = dot(dir, edgeLeft);
			}
			else
			{
				float2 edgeRight = float2(sin(_Angle*0.5f), cos(_Angle*0.5f));
				cosToEdge = dot(dir, edgeRight);
			}

			if (cosToEdge > angleThreshhold)	// 一度
			{
				float s = lerp(0, 1, (cosToEdge - angleThreshhold) / (1.0f - angleThreshhold));
				//alpha = s;
				color = lerp(color, _EdgeColor, s);
			}

			// 圆弧判断
			float len = length(input.uv - float2(0.5, 0.5));    
			if (len > 0.45f)
			{
				//color = _EdgeColor;
				float s = lerp(0, 1, (len - 0.45f) / (0.5f - 0.45f));
				//alpha = lerp(alpha, s, s);
				color = lerp(color, _EdgeColor, s);
			}
		}

		//color.a = alpha;
		return color * _Color * _ColorMultiplier;
	}
    
    ENDCG
	
	SubShader 
	{
		Tags { "RenderType"="Transparent" }
		LOD 200

		Pass
		{
			Blend SrcAlpha One
			ZWrite Off
            ZTest Always

			CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS
            #pragma target 2.0
           
            ENDCG
		}
	}
}
