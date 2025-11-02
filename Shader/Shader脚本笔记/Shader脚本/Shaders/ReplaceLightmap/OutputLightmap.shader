Shader "YueChuan/ReplaceLightmap/OutputLightmap"
 {
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
    CGINCLUDE
    #include "UnityCG.cginc"
    #include "HDREncode.cginc"

    uniform sampler2D _MainTex;
        
    struct VS_OUTPUT
    {
         float4 Position : SV_POSITION;
		 half2 vTexcoord : TEXCOORD0;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
          VS_OUTPUT output = (VS_OUTPUT)0;
                
          output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
          output.vTexcoord = input.texcoord;

          return output;
     }

     fixed4 MainPS(VS_OUTPUT input) : COLOR
     {
		 fixed4 vLightmapColor = tex2D(_MainTex, input.vTexcoord);
	     fixed3 color = UnityDecodeLightmap(vLightmapColor);
		 return EncodeLogLuv(color.rgb);
     }
     
    ENDCG
    SubShader 
	{
        Tags{ "RenderType" = "Opaque"}

		Pass
		{
        	Name "LightmapDecode"
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
