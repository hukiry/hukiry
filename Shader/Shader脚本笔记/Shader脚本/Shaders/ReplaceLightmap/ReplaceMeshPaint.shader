Shader "YueChuan/ReplaceLightmap/ReplaceMeshPaint"
 {
	Properties
	{
	      _BlendTexture("BlendTexture (RGB)", 2D) = "white" {}
	      _Texture0("Texture0 (RGB)", 2D) = "white" {}
	      _Texture1("Texture1 (RGB)", 2D) = "white" {}
	      _Texture2("Texture2 (RGB)", 2D) = "white" {}
		  _LightmapTex("Lightmap (RGBA)", 2D) = "white" {}
	}
    CGINCLUDE
    #include "UnityCG.cginc"
    //#include "HDREncode.cginc"

	sampler2D _BlendTexture;
	sampler2D _Texture0;
	sampler2D _Texture1;
	sampler2D _Texture2;
	sampler2D _LightmapTex;
   
	uniform half4 _Texture0_ST;
	uniform half4 _Texture1_ST;
	uniform half4 _Texture2_ST;

	uniform half4 unity_LightmapST;

	
	struct VS_OUTPUT
    {
         float4 Position : SV_POSITION;
		 half2 uv0 : TEXCOORD0;
		 half2 lightmapUV : TEXCOORD1;
    };

	struct appdata
	{
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD0;
		float4 texcoord1 : TEXCOORD1;

	};
            
    VS_OUTPUT MainVS(appdata input)
    {
          VS_OUTPUT output = (VS_OUTPUT)0;
                
          output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
          output.uv0 = TRANSFORM_TEX(input.texcoord, _Texture0);
		  output.lightmapUV = input.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;


          return output;
     }

	//LogLuv to FP32(RGB)
	fixed3 DecodeLogLuv(in fixed4 vLogLuv)
	{
		fixed3x3 InverseM = fixed3x3(
			6.0014, -2.7008, -1.7996,
			-1.3320, 3.1029, -5.7721,
			0.3008, -1.0882, 5.6268);

		fixed Le = vLogLuv.z * 255 + vLogLuv.w;
		fixed3 Xp_Y_XYZp;
		Xp_Y_XYZp.y = exp2((Le - 127) / 2);
		Xp_Y_XYZp.z = Xp_Y_XYZp.y / vLogLuv.y;
		Xp_Y_XYZp.x = vLogLuv.x * Xp_Y_XYZp.z;
		fixed3 vRGB = mul(Xp_Y_XYZp, InverseM);
		return max(vRGB, 0);
	}

     fixed4 MainPS(VS_OUTPUT input) : COLOR
     {
		 fixed4 b = tex2D(_BlendTexture, input.lightmapUV);
	     fixed4 tex0 = tex2D(_Texture0, input.uv0);
	     fixed4 tex1 = tex2D(_Texture1, input.uv0);
		 fixed4 tex2 = tex2D(_Texture2, input.uv0);

		 fixed4 baseColor = lerp(tex0, tex1, b.x);
		 baseColor = lerp(baseColor, tex2, b.y);

		 fixed4 lightmapColor = tex2D(_LightmapTex, input.lightmapUV);
         fixed4 decodeLightmapColor = fixed4(DecodeLogLuv(lightmapColor),1.0);
		 
		  return  baseColor * decodeLightmapColor;
     }
     
    ENDCG
    SubShader 
	{
        Tags{ "RenderType" = "Opaque"}

		Pass
		{
        	Name "ReplaceMeshPaint"

			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment MainPS
            #pragma target 2.0
           
            ENDCG
		}
    }
}
