Shader "Custom/ImageSwirl"
{
    Properties
    {
       /* [PerRendererData]*/ _MainTex("Sprite Texture", 2D) = "white" {}//[PerRendererData]隐藏纹理数据
        _Color("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap("Pixel snap", Float) = 0//[MaterialToggle]复选框 PIXELSNAP_ON  bool值，1选中，0未选中
		[PerRendererData]_Radius("Radius",float)=1//半径
		[PerRendererData]_Angle("Angle",float)=1//角度
		_count("Count",float)=8 //旋转力度
    }
 
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"//显示的视图类型，平面或球体
            "CanUseSpriteAtlas" = "True"//可以使用图集精灵
        }
 
        Cull Off//关闭剔除
        Lighting Off//关闭灯光

        ZWrite Off
        Blend One OneMinusSrcAlpha//开启透明混合
 
 
        //-----add
        //GrabPass
        //{
        //    "_MyGrabTex"
        //}
        //---------
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			// [MaterialToggle] PixelSnap("Pixel snap", Float) = 0
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"
 
            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };
 
            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord  : TEXCOORD0;
            };
 
            fixed4 _Color;
 
            //------------add
            float _Radius;
            float _Angle;
			float _count;

			sampler2D _MainTex;
            //sampler2D _MyGrabTex;//适用玻璃效果
            float2 swirl(float2 uv);
            float2 swirl(float2 uv)//旋转纹理
            {
                uv -= float2(0.5, 0.5);//先减去贴图中心点的纹理坐标,这样是方便旋转计算 

                float dist = length(uv); //计算当前坐标与中心点的距离。 

                float percent = (_Radius - dist) / _Radius;  //计算出旋转的百分比 
 
                if (percent < 1.0 && percent >= 0.0)
                {
                    //通过sin,cos来计算出旋转后的位置。 
                    float theta = pow( percent,2) * _Angle * _count;
                    float _sin = sin(theta);
                    float _cos = cos(theta);
                 
                    uv = float2(uv.x*_cos - uv.y*_sin, uv.x*_sin + uv.y*_cos);   //cos-sin,sin+cos 顺时针选转

                }

                uv += float2(0.5, 0.5);//再加上贴图中心点的纹理坐标，这样才正确。 
 
                return uv;
            }
            //---------------
 
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
				// [MaterialToggle] PixelSnap("Pixel snap", Float) = 0
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap(OUT.vertex);//顶点扭曲
                #endif
 
                return OUT;
            }

          


            fixed4 frag(v2f IN) : SV_Target
            {
                IN.texcoord = swirl(IN.texcoord);
 
                fixed4 c =tex2D(_MainTex,  IN.texcoord);
                c.rgb *= c.a;//alpha透明
                return c;
            }


 			// 			sampler2D _AlphaTex;
			//float _AlphaSplitEnabled;
 
			//fixed4 SampleSpriteTexture(float2 uv)
			//{
			//	fixed4 color = tex2D(_MainTex, uv);
 
			//	//	#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
			//	//if (_AlphaSplitEnabled)
			//	//	color.a = tex2D(_AlphaTex, uv).r;//获取R通道作为alpha值
			//	//#endif 
 
			//	return color;
			//}
            ENDCG
        }
    }
}
