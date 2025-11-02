
//
Shader "Hukiry/MaskStory"
{
    Properties
    {
	[HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}	   //指定的纹理
		_Step("Step",Range(0.0001,1))=0.15
		_Radius("Radius",Range(-0.1,0.8))=0.01
		_Pos("Input Pos",Vector)=(0.5,0.5,0.5)
		_Alpha("Alpha",Range(0,1))=0.2
		_Color("Color",Color)=(0,0,0,1)
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "RenderType"="Transparent"}
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass { }  //屏幕纹理
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
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex; //指定的纹理
            //float4 _MainTex_ST;

			sampler2D _GrabTexture : register(s0);		//屏幕纹理
			float4 _GrabTexture_ST	;	 //屏幕纹理

			float _Step;
			float _Radius;
			float2 _Pos;
			float _Alpha;

			float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _GrabTexture); 
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);   //指定的纹理
                return o;
            }

			// 创建圆
			// pos : 圆心
			//radius: 半径
			//uv: 当前像素坐标
			fixed createCircle(float2 pos,float radius,float2 uv){
				//当前像素到中心点的距离
				float dis = distance(pos,uv);
				//  smoothstep 平滑过渡, 这里也可以用 step 代替。
				float col = smoothstep(radius + _Step,radius,dis );	//椭圆
				return col ;
			}

			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = tex2D(_GrabTexture,  float2(i.uv.x,1-i.uv.y));
				fixed gray = createCircle(_Pos.xy,_Radius,i.uv);
				//gray=gray==0?_Alpha:gray;
				//gray=lerp(_Alpha,gray,gray);
				gray=lerp(gray,_Alpha,_Alpha);	//黑色过度到透明

				//fixed3 mask=fixed3(gray,gray,gray)+_Color.rgb;  //遮罩颜色变化
				fixed3 mask=fixed3(gray,gray,gray);	  //默认黑色遮罩

				return col*float4(mask,1);

			}
            ENDCG

		}
    }
}
