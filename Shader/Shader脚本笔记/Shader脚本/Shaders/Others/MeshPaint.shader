Shader "YueChuan/Others/MeshPaint"
{
	Properties
	{
		_BlendTexture ("BlendTexture (RGB)", 2D) = "white" {}
		_Texture0 ("Texture0 (RGB)", 2D) = "white" {}
		_Texture1 ("Texture1 (RGB)", 2D) = "white" {}
		_Texture2 ("Texture2 (RGB)", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		//LOD 200
		
//		pass
//		{
		
			CGPROGRAM
			#pragma surface surf Lambert
	
			sampler2D _BlendTexture;
			sampler2D _Texture0;
			sampler2D _Texture1;
			sampler2D _Texture2;
	
			struct Input
			{
				float2 uv_Texture0;
				float2 uv2_BlendTexture;
			};
	
			void surf (Input IN, inout SurfaceOutput o)
			{
				float4 b = tex2D (_BlendTexture, IN.uv2_BlendTexture);
				float4 tex0 = tex2D (_Texture0, IN.uv_Texture0);
				float4 tex1 = tex2D (_Texture1, IN.uv_Texture0);
				float4 tex2 = tex2D (_Texture2, IN.uv_Texture0);
				
				float4 color = lerp(tex0, tex1, b.x);
				color = lerp(color, tex2, b.y);
				
				o.Albedo = color.xyz;
				o.Alpha = 1.0f;
			}

//			#pragma target 3.0
//			#pragma vertex vert
//			#pragma fragment frag
//			#include "UnityCG.cginc"
//
//			sampler2D _BlendTexture;
//			sampler2D _Texture0;
//			sampler2D _Texture1;
//			sampler2D _Texture2;
//						
//			struct appdata
//			{
//				float4 vertex : POSITION;
//				float2 uv : TEXCOORD0;
//				float2 uv1 : TEXCOORD1;
//			};
//
//			struct v2f
//			{
//				float4 pos : POSITION;
//				float2 uv : TEXCOORD0;
//				float2 uv1 : TEXCOORD1;
//			};
//
//			v2f vert (appdata v)
//			{
//				v2f o;
//				o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
//				o.uv = v.uv;
//				o.uv1 = v.uv1;
//				return o;
//			}
//
//			float4 frag(v2f i) : COLOR
//			{
//				float4 b = tex2D (_BlendTexture, i.uv1);
//				float4 tex0 = tex2D (_Texture0, i.uv);
//				float4 tex1 = tex2D (_Texture1, i.uv);
//				float4 tex2 = tex2D (_Texture2, i.uv);
//				
//				float4 color = lerp(tex0, tex1, b.x);
//				color = lerp(color, tex2, b.y);
//				
//				return color;
//			}

			ENDCG
		//} // pass
	} // subshader	
	
	FallBack "Diffuse"
}
