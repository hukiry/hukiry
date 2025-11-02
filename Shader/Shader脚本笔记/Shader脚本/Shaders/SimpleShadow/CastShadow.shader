Shader "YueChuan/SimpleShadow/CastShadow" 
{
	Properties 
    {
		_ShadowColor ("Shadow Color", Color) = (0.0,0.0,0.0,1.0)
		_ShadowTex ("Base (RGB)", 2D) = "black" {}
	  }
    SubShader 
    {
        Tags {"Queue"="Transparent"}
        Pass 
        {
        	ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform fixed4 _ShadowColor;
            uniform sampler2D _ShadowTex;
            
			float4x4 _Projector;
            
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
                half4 UVShadow : TEXCOORD0;
            };

            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.Position = mul (UNITY_MATRIX_MVP, input.vertex);
				output.UVShadow = mul (_Projector, input.vertex);
               
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                fixed4 RGBColor = tex2Dproj (_ShadowTex, UNITY_PROJ_COORD(input.UVShadow));
                
                fixed4 FinalColor = RGBColor * _ShadowColor;
                FinalColor.a = (1 - RGBColor.r) * 0.45;
                return FinalColor;
            }

            ENDCG
        }
    }
}
