Shader "YueChuan/Others/FlashLight" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ExMainTex ("Ex Base (RGB)", 2D) = "white" {}
		_MaskTex ("Mask Tex", 2D) = "white" {}
		_ScrollParameter("Horizontal scrollParameter", Float) = 0
	}
    SubShader 
    {
        Tags { "Queue" = "Transparent"}

        Pass 
        {
            Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform sampler2D _ExMainTex;
            uniform sampler2D _MaskTex;
            
            uniform half _ScrollParameter;
            
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

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {
               fixed4 normalColor = tex2D(_MainTex, input.v2Texcoord);
               fixed4 lightColor = tex2D(_ExMainTex, input.v2Texcoord);
               fixed mask = tex2D(_MaskTex, input.v2Texcoord * half2(0.5,1.0) + half2(_ScrollParameter,0)).r;   
             
               //return mask;
                   fixed3 color = lerp(normalColor.rgb,lightColor.rgb,mask);
               return fixed4(color,normalColor.a);
            }

            ENDCG
        }
    }
}
