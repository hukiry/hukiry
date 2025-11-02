Shader "YueChuan/ReplaceLightmap/ReplaceCutoutDiffuse"
 {
	Properties 
	{
		_Color("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex("Base (RGB)", 2D) = "white" {}
	    _Cutoff("Alpha cutoff", Range(0, 1)) = 0.5
	    _LightmapTex("Lightmap (RGBA)", 2D) = "white" {}

	}
    CGINCLUDE
    #include "UnityCG.cginc"
    //#include "HDREncode.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _LightmapTex;

	uniform half4 unity_LightmapST;
	uniform half4 _MainTex_ST;

	uniform fixed4 _Color;
	half _Cutoff;

	
	struct VS_OUTPUT
    {
         float4 Position : SV_POSITION;
		 half2 vTexcoord0 : TEXCOORD0;
		 half2 vTexcoord1 : TEXCOORD1;
    };
            
    VS_OUTPUT MainVS(appdata_full input)
    {
          VS_OUTPUT output = (VS_OUTPUT)0;
                
          output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
          output.vTexcoord0 = TRANSFORM_TEX(input.texcoord, _MainTex);
		  output.vTexcoord1 = input.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;

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
		  fixed4 baseColor = tex2D(_MainTex, input.vTexcoord0);
	      fixed4 lightmapColor = tex2D(_LightmapTex, input.vTexcoord1);
          fixed4 decodeLightmapColor = fixed4(DecodeLogLuv(lightmapColor),1.0);
		  if (baseColor.a < _Cutoff)
			  discard;
		  return  baseColor * _Color * decodeLightmapColor;
     }
     
    ENDCG
    SubShader 
	{
        Tags{ "RenderType" = "Opaque"}

		Pass
		{
        	Name "ReplaceCutoutDiffuse"
			//Lighting off
			//Fog { Mode off }
			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment MainPS
            #pragma target 2.0
           
            ENDCG
		}
    }
}
