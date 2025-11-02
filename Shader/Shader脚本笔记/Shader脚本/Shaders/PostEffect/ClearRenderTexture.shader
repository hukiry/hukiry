Shader "YueChuan/PostEffect/ClearRenderTexture"
 {
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
	    Pass 
        {
			Lighting Off
			ZWrite Off
			AlphaTest Off
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
        
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				float2 vTexcoord : TEXCOORD0;
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
				return fixed4(0,0,0,0);
            }
            ENDCG
        }
	} 
}
