Shader "YueChuan/SimpleShadow/SimpleShadow" 
{
    Properties 
    {
		_ShadowTex ("Base (RGB)", 2D) = "black" {}
		_ShadowDensity ("Shadow Density", Range(0.0,1.0)) = 1.0
	  }
    SubShader 
    {
		Tags {"Queue"="Geometry+1"}
        Pass 
        {
        	ZWrite Off
			ZTest Off
        	
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _ShadowTex;
            uniform half _ShadowDensity;
            
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
                half2 Texcoord : TEXCOORD0;
            };

            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.Position = mul (UNITY_MATRIX_MVP, input.vertex);
				output.Texcoord = input.texcoord;
               
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                fixed4 RGBColor = tex2D (_ShadowTex,input.Texcoord);
                fixed4 FinalColor = fixed4(0,0,0,(1 - RGBColor.r) * 0.45 * _ShadowDensity);
                return FinalColor;
            }

            ENDCG
        }
    }
}
