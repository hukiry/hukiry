Shader "YueChuan/LensFlare/LensFlareSpot"
{
	 Properties 
	 {
		 _MainTex ("Base (RGB)", 2D) = "white" {}
	  }
      CGINCLUDE
      #include "UnityCG.cginc"
            
      uniform sampler2D _MainTex;
      uniform fixed4 _Color;
      uniform half  _Intensity;
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
           fixed4 color = tex2D(_MainTex,float2(1 - input.v2Texcoord.x,1 - input.v2Texcoord.y));
		   return fixed4(color.rgb * _Color.rgb * _Expose * _Intensity,color.r);
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
