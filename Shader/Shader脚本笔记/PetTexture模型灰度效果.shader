Shader "Unlit/AnimalTexture" {
	Properties {
		
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[Toggle]_IsGray("IsGray",float)=0
		[HideInInspector]_R_Alpha("R Alpha",Range(0,1))=1
		[Space(10)][Header(Custom)]
		[Toggle]_OpenColor("Use Custom Color",float)=0
		_GrayCustomColor("GrayColor",Color)=(0.299, 0.587, 0.114,1)		//
		//[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
  //      [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
		[KeywordEnum(R, G, B)] _ColorAlpha ("ColorAlpha", Float) = 0	
	}

	SubShader {
		Tags{ "Queue" = "Transparent-1" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100
	
		Pass {  
			//Blend  [_SrcBlend] [_DstBlend]
			Tags{"LightMode"="ForwardBase"}
			Name "AnimalTexture"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog

				#pragma multi_compile _COLORALPHA_R _COLORALPHA_G _COLORALPHA_B
			
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					half2 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _IsGray;
				float4 	_GrayCustomColor;
				float _R_Alpha;
				float _OpenColor;
			
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}
			
				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.texcoord);
					UNITY_APPLY_FOG(i.fogCoord, col);
					UNITY_OPAQUE_ALPHA(col.a);
					if(_IsGray)
					{
						fixed4 greyColor;  
						#if _COLORALPHA_R
						if (col.r < _R_Alpha)  
						#elif _COLORALPHA_G
						if (col.g < _R_Alpha) 
						#elif _COLORALPHA_B
						if (col.b < _R_Alpha) 
						#endif
						{  
						
							greyColor = tex2D(_MainTex, i.texcoord); 
							float grey; 
							if(_OpenColor)	 //自定义灰度元素
							{
								grey = dot(col.rgb, _GrayCustomColor);  
							}
							else 
							{	
								grey = dot(col.rgb, float3(0.299, 0.587, 0.114));  //float3(0.299, 0.587, 0.114)通用灰度	
							}
							greyColor.rgb = float3(grey, grey, grey);  
						}  
						else  
						{  
							greyColor = col;  
						} 
						return greyColor;
					}
					return col;
				}
			ENDCG
		}
	}

}