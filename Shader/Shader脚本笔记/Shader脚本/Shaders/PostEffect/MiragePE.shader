Shader "YueChuan/PostEffect/MiragePE" 
{
	 Properties 
	 {
		 _MainTex ("Base (RGB)", 2D) = "white" {}
		 _Noise ("Noise (RGB)", 2D) = "white" {}
	  }
      CGINCLUDE
      #include "UnityCG.cginc"
            
      uniform sampler2D _MainTex;
      uniform sampler2D _Noise;
      
      uniform half  _ImpulseAmount;
      uniform half  _ImpulseU;
      uniform half _Average;
        
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
           half2 texcoord = input.v2Texcoord;
           fixed4 horizontalNoise = tex2D(_Noise,half2(_ImpulseU,texcoord.y * 2));
           half base = horizontalNoise.r - _Average;
           half disth = base * base * base * _ImpulseAmount;
          
		   return tex2D(_MainTex,texcoord.xy + half2(disth,-disth));
       }
       ENDCG
       SubShader
	   {
		    Tags { "RenderType"="Opaque" }
		    LOD 200
            pass 
            {
			    Name "MiragePE"
			    Lighting Off
			    ZWrite Off
			    AlphaTest Off
        
                CGPROGRAM

                #pragma vertex VS_Main
                #pragma fragment PS_Main
                #pragma target 2.0
           
                 ENDCG
             }
       }
}
