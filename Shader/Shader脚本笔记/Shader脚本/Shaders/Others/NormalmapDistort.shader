//
//基于法线贴图的空间扭曲效果
//使用要求：
//   1、Shader用在Particle类型（平面）的特效上（例如 刀光，箭矢）
//   2、该特效的层要求是Distort层
Shader "YueChuan/Others/NormalmapDistort"
{
	Properties 
	{
	    //_MainTex ("Base (RGBA)", 2D) = "black" {}
		_DisturbTex ("Disturb Tex (RGBA)", 2D) = "black" {}
		_DisturbLevel("Disturb Level", Float) = 0.1
		//_MainTexWeight ("Main Tex Weight", Range(0.0,1.0)) = 0.5
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
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            //sampler2D _MainTex : register(s0);
            sampler2D _DisturbTex : register(s0);
            sampler2D g_colorBuffer : register(s1);
                        
            //uniform half _MainTexWeight;
            uniform half _DisturbLevel;
            uniform half4 _DisturbTex_ST;
        
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				half2 v2Texcoord : TEXCOORD0;
				half4 v4Proj : TEXCOORD1;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _DisturbTex);
                output.v4Proj = output.Position;
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                half2 v2ProjTexcoord = 0.5 * input.v4Proj.xy/input.v4Proj.w + 0.5;
                #if UNITY_UV_STARTS_AT_TOP
                v2ProjTexcoord.y = 1 - v2ProjTexcoord.y;
                #endif
                //fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
                //half alpha = v4RGBColor.a;
                fixed4 v4DisturbTex = tex2D(_DisturbTex,input.v2Texcoord);
                half3 v3DisturbNormal = v4DisturbTex.rgb * 2 - 1;
                half2 v2OffsetTexcoord = v2ProjTexcoord + v3DisturbNormal.xy * v3DisturbNormal.z * v4DisturbTex.w  * _DisturbLevel;
                fixed4 v4SceneColor = tex2D(g_colorBuffer,v2OffsetTexcoord);
               // fixed4 v4FinalColor = fixed4(lerp(v4SceneColor.rgb,v4RGBColor.rgb,alpha * _MainTexWeight),alpha);
				//return v4FinalColor;
				return v4SceneColor;
            }
            ENDCG
        }
    }
}
