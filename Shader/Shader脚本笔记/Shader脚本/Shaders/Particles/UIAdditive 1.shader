Shader "YueChuan/Particles/UIAdditive 1"
{
	Properties
	{
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_MainTex("Particle Texture", 2D) = "white" {}
		_InvFade("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	}

	Category
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha One
		AlphaTest Greater .01
		ColorMask RGB
		cull off
		Lighting Off ZWrite Off Fog{ Color(0,0,0,0) }
		SubShader
		{
			Pass
			{
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_particles

#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;

				float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
				float2 _ClipArgs0 = float2(1000.0, 1000.0);

				struct appdata_t
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
			#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD1;
			#endif
					float2 worldPos : TEXCOORD2;
				};

				float4 _MainTex_ST;

				v2f vert(appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos(o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
#endif
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
					return o;
				}

				sampler2D_float _CameraDepthTexture;
				float _InvFade;

				fixed4 frag(v2f i) : SV_Target
				{
#ifdef SOFTPARTICLES_ON
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate(_InvFade * (sceneZ - partZ));
					i.color.a *= fade;
#endif

					float2 factor = (float2(1.0, 1.0) - abs(i.worldPos)) * _ClipArgs0;
					i.color.a *= clamp(min(factor.x, factor.y), 0.0, 1.0);

					return 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					//return 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				}
				ENDCG
			}
		}
	}
}