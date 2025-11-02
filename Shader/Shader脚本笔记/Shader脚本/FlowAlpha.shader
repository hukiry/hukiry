
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "FlowAlpha" 
{
		Properties{
			
			_MainTex("Texture 主贴图", 2D) = "white" {}

			//_BumpMap("Normal 法线贴图", 2D) = "bump" {}
		   [Header(_RimColor)]
			//边缘颜色
		    _RimColor("边缘颜色", Color) = (0.231,0.933,0.890,0.5)
			//边缘系数
			_RimPower("边缘系数", Range(0.1,10.0)) = 1.0

			[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend Mode 源颜色模式", Float) = 5
			[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend Mode 目标颜色模式", Float) = 1

		    //[Toggle] _IsEmission("开启自发光", Float) = 1

			[Enum(UnityEngine.Rendering.CullMode)] _OnlyCull("Cull Mode 剔除模式", Float) = 2

			[Enum(Off, 0, On, 1)] _ZWrite("ZWrite 选择，默认关闭", Float) = 0

			[Space(20)]

			[Header(_FowTex)]
			[Toggle] _flowOpen("开启流光", Float) = 1
			_FowTex("flow 流光贴图", 2D) = "white" {}
			_flowSpeed("flowSpeed 流光速度", Range(2,10)) = 1.0
			[Enum(R, 0, G, 1,B,2,A,3)] _flowAlpha("flow Alpha 通道选择", Float) = 3

			[Header(_FlowDirection)]
			//[KeywordEnum(HORIZONTAL,VERTICAL,XY)] _FlowDirection("FlowDirection 流光方向选择", Float) = 0
			[Enum(Horzontal,0,Vertical,1,XY,2)] _FlowDirection("FlowDirection 流光方向选择", Float) = 0
		}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType"="Plane" }//Skybox  Plane Sphere
			//SrcAlpha One 透明类型输出
			Blend[_SrcBlend][_DstBlend]
			Cull [_OnlyCull]
			ZWrite [_ZWrite]
			Pass
			{
				CGPROGRAM
                //#pragma multi_compile _FLOWDIRECTION_HORIZONTAL _FLOWDIRECTION_VERTICAL _FLOWDIRECTION_XY
				#pragma vertex vert
				#pragma fragment frag
				#include"UnityCG.cginc"

				struct v2f
				{
					float4 vertex:POSITION;
					float4 uv:TEXCOORD0;
					float4 NdotV:COLOR;
				};

				sampler2D _MainTex;
				sampler2D _FowTex;
				float4 _FowTex_ST;
				float4 _RimColor;
				float _RimPower;

				float _flowSpeed;
				float _flowAlpha;
				float _FlowDirection;
				float _flowOpen;

				v2f vert(appdata_base v)
				{
					v2f o;
					//顶点转换 mul(UNITY_MATRIX_MVP, vector)
					o.vertex = UnityObjectToClipPos(v.vertex);// UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;
					//视方向从世界到模型坐标系的转换
					float3 V = mul(unity_WorldToObject,WorldSpaceViewDir(v.vertex));
					//法线和视角的点乘，用视方向和法线方向做点乘，越边缘的地方，法线和视方向越接近90度，点乘越接近0.
					o.NdotV.x = saturate(dot(v.normal,normalize(V)));
					return o;
				}

				half4 frag(v2f IN) :COLOR
				{
					half4 c = tex2D(_MainTex,IN.uv);
					//流光计算 x轴偏移

					float4 flowRGBA= float4(0,0,0,0);
					if (_flowOpen == 1)
					{
						if (_FlowDirection == 0)
						{
							flowRGBA = tex2D(_FowTex, float2(IN.uv.x / 2 + _Time.x*_flowSpeed, IN.uv.y));
						}
						else if (_FlowDirection == 1)
						{
							flowRGBA = tex2D(_FowTex, float2(IN.uv.x, IN.uv.y / 2 + _Time.x*_flowSpeed));
						}
						else if (_FlowDirection == 2)
						{
							flowRGBA = tex2D(_FowTex, float2(IN.uv.x / 2 + _Time.x*_flowSpeed, IN.uv.y / 2 + _Time.x*_flowSpeed));
						}
					}

					float flow = flowRGBA.a;
					if (_flowAlpha == 0)
					{
						flow = flowRGBA.r;
					}
					else if (_flowAlpha == 1)
					{
						flow = flowRGBA.g;
					}
					else if (_flowAlpha == 2)
					{
						flow = flowRGBA.b;
					}

					float3 lastflow = float3(flow, flow, flow);
					//用（1- 上面点乘的结果）*颜色，来反映边缘颜色情况
					c.rgb += pow((1 - IN.NdotV.x) ,_RimPower)* _RimColor.rgb;   
					c.rgb += lastflow;
					return c;
				}
				ENDCG
			}
		}
		Fallback "Diffuse"
}


//Shader "RimAlpha" { 透明外发光
//	Properties{
//		_MainTex("Texture", 2D) = "white" {}
//	_BumpMap("Bumpmap", 2D) = "bump" {}
//	_RimColor("Rim Color", Color) = (0.231,0.933,0.890,0.5)
//		_RimPower("Rim Power", Range(0.5,8.0)) = 1.0
//	}
//		SubShader{
//		Tags{
//		"Queue" = "Transparent"
//		"IgnoreProjector" = "True"
//		"RenderType" = "Transparent"
//	}
//		Blend SrcAlpha One
//		AlphaTest Greater .01
//
//		CGPROGRAM
//#pragma surface surf BlinnPhong alphatest:_Cutoff  
//
//		struct Input {
//		float2 uv_MainTex;
//		float2 uv_BumpMap;
//		float3 viewDir;
//	};
//	sampler2D _MainTex;
//	sampler2D _BumpMap;
//	float4 _RimColor;
//	float _RimPower;
//	void surf(Input IN, inout SurfaceOutput o) {
//		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
//		o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
//		half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
//		o.Alpha = pow(rim, _RimPower);
//		o.Emission = _RimColor.rgb * pow(rim, _RimPower) * 1;
//	}
//	ENDCG
//	}
//		Fallback "Diffuse"
//}