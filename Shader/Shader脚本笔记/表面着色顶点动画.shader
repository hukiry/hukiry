//表面着色顶点动画，动画Y,
Shader "Custom/VertAnimation"   
{  
    Properties   
    {  
        _MainTex ("Base (RGB)", 2D) = "white" {}  //主纹理
        _tintAmount ("Tint Amount", Range(0,1)) = 0.5  //纹理加亮

        _Speed ("Wave Speed", Range(0.1, 80)) = 5  //顶点动画的速度

        _Frequency ("Wave Frequency", Range(0, 5)) = 2  //改变x轴的坐标，sin
        _Amplitude ("Wave Amplitude", Range(-1, 1)) = 1  //幅度
    }  
      
    SubShader   
    {  
        Tags { "RenderType"="Opaque" }  
        LOD 200  
        Cull off

        CGPROGRAM  
		//Lambert 兰伯特模型，顶点动画
        #pragma surface surf Lambert vertex:vert  
  
        sampler2D _MainTex;   
        float _tintAmount; 
		 
        float _Speed;  

        float _Frequency;  
        float _Amplitude;  
  
        struct Input   
        {  
            float2 uv_MainTex;  
        };  
          
        void vert(inout appdata_full v, out Input o)  //输入数据
        {  
            float time = _Time * _Speed;  //时间

            float waveValueA = sin(time + v.vertex.x * _Frequency) * _Amplitude;  //根据x坐标的时间变化改变y坐标

            v.vertex.xyz = float3(v.vertex.x, v.vertex.y + waveValueA, v.vertex.z);  //顶点y坐标的偏移

            o.uv_MainTex = v.vertex;  //顶点坐标作为纹理坐标输入
        }  
  
        void surf (Input IN, inout SurfaceOutput o)   //只输出纹理颜色
        {  
            half4 c = tex2D (_MainTex, IN.uv_MainTex);  //纹理颜色采样
             //颜色输出
            o.Albedo = c.rgb*_tintAmount;  
			//alpha输出
            o.Alpha = c.a;  
        }  
        ENDCG  
    }   
    FallBack "Diffuse"  
}  