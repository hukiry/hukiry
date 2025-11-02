Shader "taecg/ShaderToy/Rotary Star"
{
	SubShader
	{      
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			//粒子数量
			#define NUM_PARTICLES 200.0
			//粒子半径
			#define RADIUS 0.015
			//粒子外发光
			#define GLOW 0.5

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float3 Orb(float2 uv, float3 color, float radius, float offset)
			{        
				float2 position = float2(sin(offset * (_Time.y+30.)),cos(offset * (_Time.y+30.)));
				position *= sin((_Time.y ) - offset) * cos(offset);
				radius = radius * offset;
				//通过计算UV坐标和上面的Position间的距离来绘制圆形,被除数radius的作用是控制圆形的大小
				float dist = radius / distance(uv, position);
				return color * pow(dist, 1.0 / GLOW);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//计算出屏幕宽高比(屏幕宽_ScreenParams.x除以屏幕高_ScreenParams.y)_ScreenParams为内置变量
				half ratio = _ScreenParams.x/_ScreenParams.y;
				//通过*2-1将UV的0,0点移到屏幕的中心
				half2 centerUV = i.uv*2-1;
				//同时保持UV不受屏幕比例变形
				centerUV.x*=ratio;

				float3 pixel,color=0;

				//随时间而变化的颜色
				color.r = (sin(_Time.y * 0.55) + 1.5) * 0.4;
				color.g = (sin(_Time.y * 0.34) + 2.0) * 0.4;
				color.b = (sin(_Time.y * 0.31) + 4.5) * 0.3;

				for(int i = 0.0; i < NUM_PARTICLES; i++)
				{
				    pixel += Orb(centerUV, color, RADIUS, i / NUM_PARTICLES);
				}
				
				float4 fragColor = lerp(float4(centerUV,0.8+0.5*sin(_Time.y),1.0), float4(pixel, 1.0), 0.8);
				return fragColor;
			}

			ENDCG
		}
	}
}