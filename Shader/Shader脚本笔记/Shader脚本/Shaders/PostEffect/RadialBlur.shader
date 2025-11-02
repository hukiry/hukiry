Shader "YueChuan/PostEffect/RadialBlur" 
{
	 Properties 
	 {
		 _MainTex ("Base (RGB)", 2D) = "white" {}
		 _RadialTex ("Radial Tex (RGB)", 2D) = "white" {}
		 _BlurTexSize ("BlurTexSize", Vector) = (1280,720,0,0)
		 _FocusPoint ("Focus Point", Vector) = (0.5,0.5,0,0)
		 _RadialBlurDuration ("Radial Blur Duration", Float) = 0.0
		 _RadialBlurLevel ("Radial Blur Level", Float) = 0.0
		 _FocusAreaClearLevel ("Focus Area Clear Level", Float) = 1.0
	  }
      CGINCLUDE
      #include "UnityCG.cginc"
            
      uniform sampler2D _MainTex : register(s0);
      uniform sampler2D _RadialTex : register(s1);
      uniform half4  _BlurTexSize;
      uniform half4  _FocusPoint;
      uniform half   _RadialBlurDuration;
      uniform half   _RadialBlurLevel;
      uniform half   _FocusAreaClearLevel;
        
      struct VS_OUTPUT
      {
          float4 Position : SV_POSITION;
		  half2 v2Texcoord : TEXCOORD0;
      };
            
      VS_OUTPUT VS_Main(appdata_base input)
      {
          VS_OUTPUT output = (VS_OUTPUT)0;
                
          output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
          output.v2Texcoord = input.texcoord;

          return output;
       } 
       float4 PS_RadialBlur(VS_OUTPUT input) : COLOR 
       {
           half2 v2FocusUV = _FocusPoint.xy;
           #if UNITY_UV_STARTS_AT_TOP
           v2FocusUV.y = 1 - v2FocusUV.y;
           #endif
           half2 dir = v2FocusUV - input.v2Texcoord; 
           half  dist = length(dir);
           dir /= dist;
                
           half2 ScreenParams = _BlurTexSize.xy;
           float2 v2BlurOffset[4] = 
           {
               float2(0,0.277272),
               float2(3,0.268741),
               float2(7,0.244691),
               float2(12,0.209296),
           };
           half4 v4OriColor = tex2D(_MainTex, input.v2Texcoord);
           half4 v4SumColor = v4OriColor * v2BlurOffset[0].y;
           v4SumColor += (tex2D(_MainTex, input.v2Texcoord + dir * _RadialBlurDuration * v2BlurOffset[1].x * ScreenParams.x) * v2BlurOffset[1].y);
           v4SumColor += (tex2D(_MainTex, input.v2Texcoord + dir * _RadialBlurDuration * v2BlurOffset[2].x * ScreenParams.x) * v2BlurOffset[2].y);
           v4SumColor += (tex2D(_MainTex, input.v2Texcoord + dir * _RadialBlurDuration * v2BlurOffset[3].x * ScreenParams.x) * v2BlurOffset[3].y);
				
		   return v4SumColor;
      }

      float4 PS_RadialBlend(VS_OUTPUT input) : COLOR 
      {
           half2 v2FocusUV = _FocusPoint.xy;
           #if UNITY_UV_STARTS_AT_TOP
           v2FocusUV.y = 1 - v2FocusUV.y;
           #endif
           half2 dir = v2FocusUV - input.v2Texcoord; 
           half  dist = saturate(length(dir) * 0.707107);//归一化
                
           half4 v4OriColor = tex2D(_MainTex, input.v2Texcoord);
           half4 v4RadialColor = tex2D(_RadialTex, input.v2Texcoord);
          
           half  ft = smoothstep(_FocusAreaClearLevel,1,dist) * _RadialBlurDuration * _RadialBlurLevel;
           return lerp(v4OriColor,v4RadialColor,saturate(ft));
       }
       ENDCG
       SubShader
	   {
		    Tags { "RenderType"="Opaque" }
		    LOD 200
            pass 
            {
			    Name "RadialBlur"
			    Lighting Off
			    ZWrite Off
			    AlphaTest Off
        
                CGPROGRAM

                #pragma vertex VS_Main
                #pragma fragment PS_RadialBlur
                #pragma target 2.0
           
                 ENDCG
             }
		     pass 
             {
			     Name "RadialBlurBlend"

		       	 Lighting Off
			     ZWrite Off
			     AlphaTest Off
        
                 CGPROGRAM

                 #pragma vertex VS_Main
                 #pragma fragment PS_RadialBlend
                 #pragma target 2.0
           
                 ENDCG
             }
       }
}
