// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "swan/FlowLight (Alpha)"
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
		_Color("颜色", Color) = (1, 1, 1, 1)
		_IsShow("是否显示", int) = 1
	}
	SubShader
	{
		Tags{ "QUEUE" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Geometry" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

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

			fixed4 _Color;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
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
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				if (_IsShow == 1)
				{
					fixed4 maskTex = tex2D(_MainMaskTex, i.uv);

					half2 flowUV = i.uv;

					flowUV = flowUV + _Time.y * _FlowSpeed * half2(_XDir, _YDir);

					fixed4 flowTex = tex2D(_FlowTex, TRANSFORM_TEX(flowUV, _FlowTex)) * _FlowPow * maskTex * _FlowColor;
					mainTex += fixed4(flowTex.rgb, 0);
				}
				return mainTex * _Color;
			}
			ENDCG
			}
		}
		FallBack "DZ/DoubleFace"
}
