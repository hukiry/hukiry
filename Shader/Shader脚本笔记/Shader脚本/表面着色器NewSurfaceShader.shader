Shader "Custom/NewSurfaceShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }//描述渲染类型，当前是不透明的物体
		//Tags { "RenderType"="Opaque" "queue" = "transparent"}//透明的物体
		LOD 200 //层级细节
		
		CGPROGRAM//CG代码块
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows//编译指令
//surface表面着色器 surf调用的方法 Standard基于物理的光照模型(原来是漫反射 Lambert)
//fullforwardshadows 阴影表现（平行光、点光、聚光都是有阴影的）

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0 //GPU硬件支持3.0 不写默认是2.0

		sampler2D _MainTex;//CG 中的图片类型

		struct Input {
			float2 uv_MainTex;//记录uv纹理坐标
		};

		half _Glossiness;//CG中的浮点型
		half _Metallic;
		fixed4 _Color;//CG中的四阶向量

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;//金属光泽表现
			o.Smoothness = _Glossiness;//高光光泽度
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
