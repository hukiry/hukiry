//用在侠客预览UITexture上
Shader "YueChuan/Particles/CharacterPreview" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_PreviewMask ("Preview", 2D) = "white" {}
	}
    SubShader 
    {
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}     
        Pass 
        {
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend One OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform sampler2D _PreviewMask;
            
            
            uniform half4 _MainTex_ST;
            
            struct VS_OUTPUT
            {
                float4 v4Position : SV_POSITION;
                half2 v2Texcoord : TEXCOORD0;
            };

            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.v4Position = mul (UNITY_MATRIX_MVP, input.vertex);
				output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
               
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
               fixed4 color = tex2D(_MainTex, input.v2Texcoord);
               fixed  previewMask = tex2D(_PreviewMask, input.v2Texcoord).r;
               
               return color * previewMask;
            }

            ENDCG
        }
    }
}
