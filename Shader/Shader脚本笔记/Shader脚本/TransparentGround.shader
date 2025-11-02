Shader "YueChuan/Others/TransparentGround" 
{
	Properties 
	{
	
	}
    SubShader 
    {
        Tags
        {
            //"Queue"="Transparent"
            //"RenderType"="Transparent"
        }
        Pass 
        {
        	//ZWrite Off
			//AlphaTest Greater 0
			ColorMask A
			
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            struct VS_OUTPUT
            {
                float4 v4Position : SV_POSITION;
                half2 v2Texcoord : TEXCOORD0;
            };

            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.v4Position = mul (UNITY_MATRIX_MVP, input.vertex);
				output.v2Texcoord = input.texcoord;
               
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
               return fixed4(0,0,0,0);
            }

            ENDCG
        }
    }
}
