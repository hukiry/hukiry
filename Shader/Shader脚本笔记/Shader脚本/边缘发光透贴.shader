// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//除去半透明效果，请到C#脚本中修改：material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);动态修改值
Shader "Custom/TextureAlphaBlendTwo"
{
	Properties
	{
		_MainTex("Base (RGB)主贴图", 2D) = "white" {}
		[Space(10)]
	    [Toggle] _IsOpen("开启边缘颜色发光，Main Color主颜色将被取消", Float) = 1
	    _RimColor("Rim Color边缘颜色",Color) = (0,1,1,1)
		[PowerSlider(10.0)]_RimPower("Rim Alpha 边缘系数", Range(0.01,10)) =0.01

		[Space(10)]
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend Mode 源颜色模式", Float) =3
	    //material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);动态修改值
		[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend Mode 目标颜色模式", Float) = 6
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode 剔除模式", Float) = 0

		[HideInInspector]
		[Enum(Off, 0, On, 1)] _ZWrite("ZWrite 选择，默认关闭", Float) = 1

		[Space(20)][Header(_Color)]
		_Color("Main Color主颜色", Color) = (1,1,1,1)
		[PowerSlider(8.0)]_Alpha("Alpha", Range(0,1)) = 1.0


		[Toggle] _IsShine("IsShine 开启外发光", Float) = 1
	}
		
	SubShader
	{
		LOD 300
		Tags{ "Queue" = "Transparent+500" "RenderType" = "Queue"  "PreviewType" = "Sphere" }//Skybox  Plane Sphere
		pass
	    {
			//Blend SrcAlpha OneMinusSrcAlpha // 传统透明度  
			//Blend One OneMinusSrcAlpha // 预乘透明度  
			//Blend One One // 叠加  
			//Blend OneMinusDstColor One // 柔和叠加  
			//Blend DstColor Zero // 相乘——正片叠底  
			//Blend DstColor SrcColor // 两倍相乘  
			Blend[_SrcBlend][_DstBlend]

			ZWrite [_ZWrite]
			ZTest LEqual//less
			Cull [_Cull]

			CGPROGRAM
			#pragma vertex vert    
			#pragma fragment frag    
			#include "UnityCG.cginc"  
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _RimColor;
			float _RimPower;

			fixed4 _Color;
			fixed _intensity;
			fixed _Alpha;

			fixed _IsShine;
			float _IsOpen;

			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 normal:NORMAL;
			};

			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float4  color:COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				//将模型空间的顶点坐标转换为裁剪区的坐标
				o.pos = UnityObjectToClipPos(v.vertex);
				//计算模型空间顶点到视角方向，标准化
				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				//视线与法线垂直的部分（点乘为0）即是外轮廓，加重描绘 //，反射光集中到中心，取反变成边缘发光
				float rim = saturate(dot(viewDir, v.normal));
				if (_IsShine)
				{
					rim = 1 - saturate(dot(viewDir, v.normal));
				}
				//颜色发光计算
				o.color = _RimColor*pow(rim, _RimPower);
				//模型自身uv坐标
				o.uv = v.texcoord;

				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				//采样主纹理，混合自定义颜色，这里不是叠加
				float4 texCol = tex2D(_MainTex, i.uv)*_Color;// *_intensity;
				//纹理透明度显示
				texCol.rgb *= _Alpha;

				if (_IsOpen)
				{
					texCol = tex2D(_MainTex, i.uv)*i.color;
					return texCol;
				}

				return texCol;
			}
			ENDCG
	     }
	}
		Fallback "Transparent/VertexLit"
}