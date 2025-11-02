Shader "Custom/DistanceMelt"
{
	Properties
	{
		[NoScaleOffset]_MainTex("主贴图", 2D) = "white" {}
		_MaxDistance("影响半径",float) = 0.5
		_NoiseTex("噪声贴图",2D) = "black"{}
		_XDensity("噪声密度(水平)", float) = 1
		_YDensity("噪声密度(竖直)", float) = 1
		_MeltPoint("消融点坐标",Vector)=(0,0,0,1)
		_NoiseEffect("噪声影响占比",Range(0,1))=0.5
		[NoScaleOffset]_EdgeColor("消融边缘贴图",2D) = "black"{}
		_ColScale("颜色比例",float)  = 1
		_EdgeWidth("消融边缘宽度",Range(0,1)) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uvMain : TEXCOORD0;
					float2 uvNoise : TEXCOORD1;
					float4 objPos : TEXCOORD2;
				};

				sampler2D _MainTex;
				sampler2D _NoiseTex;
				sampler2D _EdgeColor;
				float4 _NoiseTex_ST;
				float4 _MeltPoint;
				float _Threshold;
				float _XDensity;
				float _YDensity;
				float _EdgeWidth;
				float _MaxDistance;
				fixed _NoiseEffect;
				float _ColScale;
				float _DelayTime;

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uvMain = v.uv;
					_NoiseTex_ST.xy *= float2(_XDensity, _YDensity);//改变噪声贴图缩放来控制噪声密度
					o.uvNoise = TRANSFORM_TEX(v.uv, _NoiseTex);
					o.objPos = v.vertex;//保留物体的物体空间坐标，为后续计算距离准备
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float4 PointPos = mul(unity_WorldToObject , _MeltPoint);//将世界坐标的目标点转到物体空间坐标
					float Distance = length(i.objPos - PointPos);//计算他们在物体空间坐标的距离
					fixed noise = tex2D(_NoiseTex, i.uvNoise).r;//采样噪声，后续将对消融距离进行扰动
					//noise*_NoiseEffect表示噪声扰动的影响程度
					//Distance减去noise*_NoiseEffect完成对距离的扰动影响
					//最后减去_MaxDistance判断影响后的距离是否大于最大距离，小于就剔除，大于就保留像素
					fixed cutout = Distance - noise * _NoiseEffect - _MaxDistance;
					clip(cutout);//cutout小于0剔除像素，反之保留像素
					fixed4 col = tex2D(_MainTex, i.uvMain);
					//cutout若大于0即可表示成与_MaxDistance的距离，除于_EdgeWidth并约束到0~1转化1成uv即可完成根据与_MaxDistance的距离查找uvEdgeCol对应的颜色
					//_ColScale对uv.x进行缩放，完成水平方向对EdgeCol自定义分配，数值越大，采样约接近EdgeCol的深黑色部分
					//EdgeCol帖图的导入设置中wrap mode要设为clamp
					fixed2 uvEdgeCol = fixed2(_ColScale*smoothstep(0, 1, cutout / _EdgeWidth), smoothstep(0, 1, cutout / _EdgeWidth));
					fixed4 edgeCol = tex2D(_EdgeColor, uvEdgeCol);
					//根据与_MaxDistance的距离与_EdgeWidth的占比来过渡MainTex颜色与边缘颜色edgeCol
					fixed f= smoothstep(0, 1, cutout / _EdgeWidth);
					col = lerp(edgeCol, col, f);
					return col;
				}
				ENDCG
			}
		}
}
