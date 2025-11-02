//顶点动画
Shader "Custom/Circle"
{
    Properties
    {
        //[KeywordEnum(X, Y,Z,W)] _FadeWith ("Fade With", Float) = 0 ;类似于枚举[KeywordEnum(X, Y,Z,W)]
         _MainTex ("MainTex", 2D) =""{}
		_speed("speed", float )=1
		_move("move", float )=1
    }
    SubShader
    {
		Tags{
		"Queue"="Transparent" "IgnoreProject"="True" "RenderTyep"="Transparent"
		}
		Lighting off
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

            sampler2D _MainTex;
			float4 _MainTex_ST;

			  sampler2D _back;
			float4 _back_ST;
			float _speed;
			float _move;


            v2f vert (appdata v)
            {
                v2f o;

				float4 offsetPos=float4(0,0,0,0);

				offsetPos.x=sin(_Time.x*_speed+v.vertex.y*_move+v.vertex.z*_move+v.vertex.w*_move);//顶点水波纹动画，x

                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex+offsetPos);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            //注意，uv的最大值是(1, 1)
            fixed4 frag (v2f i) : SV_Target
            {
				float4 col=tex2D(_MainTex,i.uv);
				return col;
            }
            ENDCG

        }
    }
}
