//
//基于网格的空间震荡扭曲效果
//使用要求：
//   1、Shader用在网格顶点动画（例如 爆炸动画）
//   2、该网格的层要求是Distort层
Shader "Custom/GridVertexDistort" 
{
  	Properties 
	{
		_DisturbLevel("Disturb Level", Float) = 1
	}
    SubShader 
    {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent+100"}

        // Grab the screen behind the object into _GrabTexture
        GrabPass 
        { 
            "g_colorBuffer"
        }

        // Render the object with the texture generated above, and invert it's colors
        Pass 
        {
            Fog { Mode Off }
			Lighting Off
			ZWrite Off
			ZTest LEqual
			//Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            sampler2D g_colorBuffer : register(s0);
            
            uniform half _DisturbLevel;
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				half3 v3Normal : TEXCOORD0;
				half4 v4Proj : TEXCOORD1;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v3Normal = normalize(mul((float3x3)UNITY_MATRIX_MVP, input.normal));
                output.v4Proj = output.Position;
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                half2 v2ProjTexcoord = (0.5 * input.v4Proj.xy / input.v4Proj.w) + half2(0.5,0.5);
                #if UNITY_UV_STARTS_AT_TOP
                v2ProjTexcoord.y = 1 - v2ProjTexcoord.y;
                #endif
                half2 v2OffsetTexcoord = v2ProjTexcoord - input.v3Normal.xy  * input.v3Normal.z * half2(-_DisturbLevel,_DisturbLevel);
                fixed4 v4SceneColor = tex2D(g_colorBuffer,v2OffsetTexcoord);
				return v4SceneColor;
            }
            ENDCG
        }
    }
}
