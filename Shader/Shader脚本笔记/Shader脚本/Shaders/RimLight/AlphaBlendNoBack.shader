Shader "YueChuan/Others/AlphaBlendNoBack" {
Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Base (RGB)", 2D) = "White" {}
		
		_EmissionAmount ("Emissive Amount", Float) = 1.0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "CharacterInfo.cginc"
   
    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        return output;
    }

    fixed4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
        fixed4 v4Color = CharacterColor(v4RGBColor,fixed4(0,0,0,0));
        return v4Color;
    }

    ENDCG

    SubShader
	{
		Tags {"RenderType"="Transparent" "Queue"="Transparent+401" "LightMode" = "Vertex"}
		LOD 200

	    Pass 
        {
			ZTest Less

            Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
           //ZWrite Off

            CGPROGRAM           
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
			ENDCG
        }
		
   }
}