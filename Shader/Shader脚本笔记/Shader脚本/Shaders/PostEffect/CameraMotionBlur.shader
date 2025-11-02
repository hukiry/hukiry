Shader "YueChuan/PostEffect/CameraMotionBlur" 
{
	   Properties 
	   {
		   _MainTex ("Base (RGB)", 2D) = "white" {}
		  // _MaskTex ("Mask Tex", 2D) = "black" {}
		  _SampleLength ("Sample Length", Vector) = (0,0,0,0)
		  
	   }
	   SubShader
	   {
		    Tags { "RenderType"="Opaque" }
		    LOD 200
            pass 
            {
			    Name "MotionBlur"
			    Lighting Off
			    ZWrite Off
			    AlphaTest Off
        
                CGPROGRAM

                #pragma vertex VS_Main
                #pragma fragment PS_MotionBlur
                #pragma target 2.0
           
                ENDCG
             }
        }
        CGINCLUDE
        #include "UnityCG.cginc"
        
        uniform sampler2D _MainTex : register(s0);
       // uniform sampler2D _MaskTex : register(s1);
        uniform sampler2D _CameraDepthTexture : register(s1);
                    
        uniform float4x4 g_matViewProjInverse;
        uniform float4x4 g_matPreFrameViewProj;
        uniform float4   _SampleLength;

        struct VS_OUTPUT
        {
             float4 Position : SV_POSITION;
		     float2 v2Texcoord : TEXCOORD0;
        };
            
         VS_OUTPUT VS_Main(appdata_base input)
         {
             VS_OUTPUT output = (VS_OUTPUT)0;
             output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
             output.v2Texcoord = input.texcoord;

             return output;
         }

         float4 PS_MotionBlur(VS_OUTPUT input) : COLOR 
         {
               float2 v2BlurOffset[5] = 
               {
                     float2(0.0,0.237355),
                     float2(0.4,0.230052),
                     float2(0.4,0.209465),
                     float2(0.4,0.179165),
                     float2(0.4,0.143963),
                };
				float zOverW = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture,input.v2Texcoord));
				float4 H = float4(input.v2Texcoord.xy * 2.0 - 1.0,zOverW,1);
             	float4 D = mul(g_matViewProjInverse,H);
	            float4 v4WPosition = D / D.w;
	            
	            float4 currFramePos = H;
	            float4 preFramePos = mul(g_matPreFrameViewProj,v4WPosition);
                preFramePos /= preFramePos.w;
	            float2 v2Velocity = currFramePos - preFramePos;    
	            
	            float2 v2Texcoord = input.v2Texcoord;
	            float4 v4RGBColor = 0;
	            for(int i = 0; i < 5; ++i)
	            {
                      //float v4MaskU = tex2D(_MaskTex,input.v2Texcoord.xx);
                      //float v4MaskV = tex2D(_MaskTex,input.v2Texcoord.yy);
		              float4 currColor = tex2D(_MainTex,v2Texcoord)* v2BlurOffset[i].y; 
	                  v4RGBColor += currColor;
	                  
	                  v2Texcoord -= (v2Velocity * v2BlurOffset[i].x * _SampleLength.xy);
               	}
	            float4 v4FinalColor = v4RGBColor;;
				return v4FinalColor;
         }
         ENDCG
}
