Shader "YueChuan/LensFlare/LensFlareSpotOcllusion" 
{
	 Properties 
	 {
		 _MainTex ("Base (RGB)", 2D) = "white" {}
		 _OcllusionTex ("Ocllusion Tex", 2D) = "white" {}
	  }
      CGINCLUDE
      #include "UnityCG.cginc"
            
      uniform sampler2D _MainTex;
      uniform sampler2D _OcllusionTex;
     
      uniform fixed4 _Color;
      uniform half  _Intensity;
      uniform half4 _SunUV;
	  uniform half  _Expose;

        
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
       
       fixed4 PS_Main(VS_OUTPUT input) : COLOR 
       {	 
           half3 v3Offset[5] = 
           {
              half3(0,0,0.2),
              half3(-8,0,0.2),
              half3(8,0,0.2),
              half3(0,-8,0.2),
              half3(0,8,0.2)
           };
           half2 v2SunUV = _SunUV.xy;
           #if UNITY_UV_STARTS_AT_TOP
               v2SunUV.y = 1 - v2SunUV.y;
           #endif
           fixed4 color = tex2D(_MainTex,input.v2Texcoord);
           fixed ocllusion = tex2D(_OcllusionTex,v2SunUV + v3Offset[0].xy/_ScreenParams.xy).r * v3Offset[0].z;
           ocllusion += tex2D(_OcllusionTex,v2SunUV + v3Offset[1].xy/_ScreenParams.xy).r * v3Offset[1].z;
           ocllusion += tex2D(_OcllusionTex,v2SunUV + v3Offset[2].xy/_ScreenParams.xy).r * v3Offset[2].z;
           ocllusion += tex2D(_OcllusionTex,v2SunUV + v3Offset[3].xy/_ScreenParams.xy).r * v3Offset[3].z;
           ocllusion += tex2D(_OcllusionTex,v2SunUV + v3Offset[4].xy/_ScreenParams.xy).r * v3Offset[4].z;
           
		   return fixed4(color.rgb * _Color.rgb * _Intensity * ocllusion * _Expose,color.r);
       }
       ENDCG
       SubShader
	   {
	       Tags 
	       {
		     "Queue"="Transparent"
		     "IgnoreProjector"="True"
		     "RenderType"="Transparent"
		     "PreviewType"="Plane"
	        }
		    LOD 200
            pass 
            {
			    Name "LensFlareSpot"
			    Lighting Off
			    ZWrite Off
			    AlphaTest Off
			    cull off
                //Blend SrcAlpha OneMinusSrcAlpha
                Blend one one
                CGPROGRAM

                #pragma vertex VS_Main
                #pragma fragment PS_Main
                #pragma target 2.0
           
                 ENDCG
             }
       }
}
