Shader "YueChuan/LensFlare/LensFlareOcllusion"
{
	 Properties 
	 {
		 _MainTex ("Base (RGB)", 2D) = "white" {}
	  }
      CGINCLUDE
      #include "UnityCG.cginc"
      
      sampler2D _MainTex;
        
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
		   return 1 - tex2D(_MainTex,input.v2Texcoord).a;
       }
       ENDCG
       SubShader
	   {
	       Tags 
	       {
		     "Queue"="Transparent"
		     "IgnoreProjector"="True"
	        }
		    LOD 200
            pass 
            {
			    Name "LensFlareOcllusion"
			    Lighting Off
			    AlphaTest Off
                CGPROGRAM

                #pragma vertex VS_Main
                #pragma fragment PS_Main
                #pragma target 2.0
           
                 ENDCG
             }
       }
}
