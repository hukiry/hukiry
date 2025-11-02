// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "swan/FlowLight"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MainMaskTex("遮罩", 2D) = "white" {}
		_FlowTex ("流光贴图", 2D) = "black" {}
		_FlowSpeed ("流光速度", float) = 5
		_FlowPow ("流光贴图亮度", float) = 3
		_FlowColor("流光颜色", Color) = (1, 1, 1, 1)

		_XDir("UV的X方向", float) = 0
		_YDir("UV的Y方向", float) = 0.5
		_IsShow("是否显示流光", int) = 1
	}
	SubShader
	{
		Tags{ "QUEUE" = "Geometry" "IGNOREPROJECTOR" = "true" "RenderType" = "Geometry" }

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			sampler2D _MainMaskTex;

			sampler2D _FlowTex;

			float4 _FlowTex_ST;

			float _FlowSpeed;

			float _FlowPow;

			float _XDir;

			float _YDir;

			fixed4 _FlowColor;

			int _IsShow;

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert (appdata_base v)
			{
					v2f OUT;
					OUT.pos = UnityObjectToClipPos(v.vertex);
					OUT.uv = v.texcoord.xy;
					return OUT;
			}

			float4 frag(v2f i) : COLOR
			{
				//纹理采样
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				if (_IsShow == 1)
				{
					//遮罩采样
					fixed4 maskTex = tex2D(_MainMaskTex, i.uv);
					half2 flowUV = i.uv;
					//添加流光方向偏移量，时间 _Time.y加流光速度
					flowUV = flowUV + _Time.y * _FlowSpeed * half2(_XDir, _YDir);
					//流光贴图采样  混合遮罩贴图和流光颜色
					fixed4 flowTex = tex2D(_FlowTex, TRANSFORM_TEX(flowUV, _FlowTex)) * _FlowPow * maskTex * _FlowColor;
					//在主贴图上叠加流光效果
					mainTex += flowTex;
				}
				return mainTex;
			}
			ENDCG
			}
		}
		FallBack "DZ/DoubleFace"
}
