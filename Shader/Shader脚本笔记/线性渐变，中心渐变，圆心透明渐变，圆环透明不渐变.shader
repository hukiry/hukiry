//线性渐变，中心渐变，圆心透明渐变，圆环透明不渐变
Shader "Custom/Circle"
{
    Properties
    {
        [KeywordEnum(X, Y,Z,W)] _FadeWith ("Fade With", Float) = 0
         _Color1 ("Color1", Color) = (1.0,1.0,1.0,1.0)
         _Color2 ("Color2", Color) = (0.0,0.0,0.0,1.0)
        [PowerSlider(1)] _Weights ("Weights", Range (0.0, 3.0)) = 2.0
		_MoveLine("_MoveLine", Range (0.0, 100)) = 1.0
    }
    SubShader
    {
	Tags{
	"Queue"="Transparent" "IgnoreProject"="True" "RenderTyep"="Transparent"
	}
	Cull Off //关闭剔除，正反都可以看见
	ZWrite Off//关闭深度，不写入缓存区
	blend SrcAlpha OneMinusSrcAlpha//开启透明通道
        Pass
        {
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color1;
            fixed4 _Color2;
            float _Weights;
			float _MoveLine;
            //计算给定uv点到经过linePoint的直线line的距离
            float getPointLineDist(float2 uv, float2 linePoint, float2 ln)
            {
                float2 point2point = uv - linePoint;//所有uv点到linePoint点
                float dist= length(dot(uv, ln) * ln/length(ln) - point2point);
                return dist;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.uv;
                return o;
            }

            //注意，uv的最大值是(1, 1)
            fixed4 frag (v2f i) : SV_Target
            {
				//一颜色线性渐变插值混合
                float2 linePoint = float2(1,1);
                float2 ln = float2(-1, 1);      //line
                float pointLineDist = getPointLineDist(i.uv.xy, linePoint, ln);//获得的线性坐标
                float maxLineDist = getPointLineDist(float2(0, 0), linePoint, ln);
                float lp = pointLineDist / maxLineDist * _Weights;
				//fixed4 col = lerp(_Color1, _Color2, lp);//颜色线性渐变插值混合


				//二圆心渐变
				float x=length(i.uv-float2(0.5,0.5))*_MoveLine;
				fixed4 col=lerp(_Color1, _Color2,x);

			
				//三圆形渐变，其他透明
				//if(col.b<0.1)
				//{
				//	col.a=0;
				//}

				//四圆环，不渐变
				float a=sin(x);//
				if(a<0.01)
				{
					col.a=0;
				}
                return col;
            }
            ENDCG

        }
    }
}
