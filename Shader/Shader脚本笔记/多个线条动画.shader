Shader "JQM/#Name#"
{
    //属性快
    Properties
    {
	_MainTex("MainTex",2D)=""{}
        _Color("Base Color",Color) = (1,1,1,1)
		
		_MainTint ("Main Color", Color) = (1, 1, 1, 1)
		_Light("LineWidth",Range(0.0,0.2))=0.01		//线的框
		_minCount("minCount",Range(0,50))=7		//流动的范围
		_maxCount("maxCount",Range(0,50))=10	//线的个数
		[PowerSliderDrawer]_raduis("raduis",Range(0.01,1.0))=0.1
		[PowerSliderDrawer]_circleWidth("circleWidth",Range(0.01,1.0))=0.1
    }

    
    SubShader
    {
		Tags{"Queue"="Transparent" "RenderType"="Transparent" "IgnoreProject"="True"}
        Pass
        {
			Tags{
			   "LightMode"="ForwardBase"
			}

           Blend SrcAlpha OneMinusSrcAlpha
 			Cull Off  
            ZWrite Off 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _MainTint;
            //顶点着色器
            VertexOutput vert (appdata_full v)
            {
                VertexOutput o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
                return o;
            }

            //像素着色器
            fixed4 frag (VertexOutput i) : COLOR
            {
				float4 mainColor=tex2D(_MainTex, i.uv);
				return mainColor;
            }
            ENDCG
        }

		Pass  //多个线条动画
        {
			Tags{
			   "LightMode"="ForwardBase"
			}

            Blend SrcColor one
            Cull Off  
            Lighting Off  
            ZWrite Off  
           // Ztest Greater  
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float4 _Color;
			float4 _MainTint;
			float _minCount;
			float _maxCount;
			float  _Light;

            //顶点着色器
            VertexOutput vert (appdata_full v)
            {
                VertexOutput o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv.xy = v.texcoord.xy;
                return o;
            }

            //像素着色器
            fixed4 frag (VertexOutput i) : COLOR
            {
                float2 uv = i.uv.xy;
                uv = uv*2.0 -1.0;
                float wave_width;

                float3 color1 = float3(0,0,0);

                for(float i=0.0; i<_maxCount; i++) 
                {  
                    uv.y +=  sin(uv.x + i/_minCount+  _Time.y)/_minCount;  
                    wave_width = abs(1.0 /uv.y*_Light);  
                    color1.xyz += fixed3(wave_width, wave_width, wave_width);  
                }
                return float4(color1.xyz,1)*_Color;
            }
            ENDCG
        }

		//Pass   //一个圆环
  //      {
		//	Tags{
		//	   "LightMode"="ForwardAdd"
		//	}
		//	Blend SrcAlpha OneMinusSrcAlpha
		//	ZWrite Off
  //          CGPROGRAM
  //          #pragma vertex vert
  //          #pragma fragment frag
            
  //          #include "UnityCG.cginc"

  //          struct VertexOutput
  //          {
  //              float4 pos : SV_POSITION;
  //              float2 uv : TEXCOORD0;
                
  //          };

		//	sampler2D _MainTex;
		//	float _raduis;
		//	float _circleWidth;

  //          //顶点着色器
  //          VertexOutput vert (appdata_full v)
  //          {
  //              VertexOutput o;
  //              o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
  //              o.uv = v.texcoord.xy;
  //              return o;
  //          }

  //          //像素着色器
  //          fixed4 frag (VertexOutput i) : COLOR	
  //          {
		//		fixed4 col=tex2D(_MainTex,i.uv);
		//		float2 center=float2(0.5,0.5);
		//		float2 uv = i.uv-center;
		//		float centerDistance=length(uv);
		//		float r= fmod(_Time.x,_raduis);
		//		if(centerDistance<r||centerDistance>r+_circleWidth)
		//		{
		//			col.a=1;
		//		}
		//		else 
		//		{
		//			col.a=0;
		//		}
  //              return col;
  //          }
  //          ENDCG
  //      }

    }
}