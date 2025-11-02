Shader "YueChuan/FogOfWar/FinalFogOfWar"
 {
	 Properties
	 {
		 _FogOfWarTex("Translucent FogOfWar Texture", 2D) = "white" {}
	     _TerritoryMaskTex("TerritoryMask Tex", 2D) = "white" {}
	 }
    CGINCLUDE
    #include "UnityCG.cginc"
    
    uniform half4 _ViewCenter;
    uniform half  _BufferAspect;
    
	uniform sampler2D _FogOfWarTex;
	uniform sampler2D _TerritoryMaskTex;
	uniform sampler2D _NoiseTex;
        
    struct VS_OUTPUT
    {
         float4 Position : SV_POSITION;
		 half2 v2Texcoord : TEXCOORD0;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
          VS_OUTPUT output = (VS_OUTPUT)0;
                
          output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
          output.v2Texcoord = input.texcoord;

          return output;
     }

     fixed4 MainPS(VS_OUTPUT input) : COLOR 
     {    
           fixed4 v4FogOfWarTex = tex2D(_FogOfWarTex,input.v2Texcoord);
	       fixed territoryMask = tex2D(_TerritoryMaskTex, input.v2Texcoord);

           fixed noise = tex2D(_NoiseTex,input.v2Texcoord).r;
           half2 AB = half2(_ViewCenter.z,_ViewCenter.z * _BufferAspect) * noise;
           half M = ((input.v2Texcoord.x - _ViewCenter.x) * (input.v2Texcoord.x - _ViewCenter.x))/(AB.x * AB.x);
           half S = ((input.v2Texcoord.y - _ViewCenter.y) * (input.v2Texcoord.y - _ViewCenter.y))/(AB.y * AB.y);
           half dist = M + S;
           half alpha = smoothstep(AB.x - _ViewCenter.w,AB.x + _ViewCenter.w,dist);
		   
		   return float4(0,0,0,min(territoryMask,v4FogOfWarTex.a * alpha));
     }
    ENDCG
    SubShader 
	{
        Tags{ "RenderType" = "Opaque" "Queue"="Geometry" }

		Pass
		{
        	Name "FogOfWarEx"
        	Lighting Off
			ZWrite Off
			AlphaTest Off
			
			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment MainPS
            #pragma target 2.0
           
            ENDCG
		}
    }
}
