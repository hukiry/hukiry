//纹理溶解
Shader "Dissolve_TexturCoords"
{
	 Properties {  
       _Color ("Color", Color) = (1,1,1,1)		  // 主色  
       _MainTex ("MainTex", 2D) = "white" {}	  // 主材质  
       _DissolveText ("溶解贴图", 2D) = "white" {}// 溶解贴图  
       _Amount ("溶解值", Range (0, 1)) = 0.5     // 溶解度  
    }  
    SubShader {   
        Tags { "RenderType"="Opaque" }  
        LOD 200  
        Cull off  
      
        CGPROGRAM  
        #pragma target 3.0  
		//BlinnPhong模型
        #pragma surface surf BlinnPhong  
  
        sampler2D _MainTex;  
        sampler2D _DissolveText;  //溶解贴图
        fixed4 _Color;          // 主色  
        half _Amount;           // 溶解度  

        struct Input {  
            float2 uv_MainTex;  // 只需要主材质的UV信息  
        };  
  
        void surf (Input IN, inout SurfaceOutput o) {  
           
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);  // 对主材质进行采样   
           
            o.Albedo = tex.rgb * _Color.rgb;  // 设置主材质和颜色   
            
            float ClipTex = tex2D (_DissolveText, IN.uv_MainTex).g; // 对裁剪材质进行采样，取R色值  
  
            float ClipAmount = ClipTex - _Amount; // 裁剪量 = 裁剪材质R - 外部设置量  
			 
            if(_Amount > 0)  
            {  
                if(ClipAmount < 0) // 如果裁剪材质的R色值 < 设置的裁剪值  那么此点将被裁剪  
                {  
                    clip(-0.1);  
                }
            }  
            o.Alpha = tex.a * _Color.a;  
        }  
        ENDCG  
    }
}
