Shader "YueChuan/Others/Dissolve" 
{
    Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_DissolveColor ("Dissolve Color", Color) = (1.0,0.0,0.0,1.0)
		_MainTex ("Base (RGB)", 2D) = "White" {}
		_NoiseTex ("Noise", 2D) = "White" {}
		
		_DissolveSpeed ("Dissolve Speed", Range(0,10)) = 1.0
		_DissolveWidth ("Dissolve Width", Range(0,1)) = 0.02
	}

	CGINCLUDE
	#include "UnityCG.cginc"
   
    uniform sampler2D _MainTex;
    uniform sampler2D _NoiseTex;
    uniform half4 _MainTex_ST;
    uniform half4 _NoiseTex_ST;
    
    uniform fixed4 _DissolveColor;
    uniform half _DissolveSpeed;
    uniform half _DissolveWidth;
   
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord0 : TEXCOORD0;
        half2 v2Texcoord1 : TEXCOORD1;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord0 = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.v2Texcoord1 = TRANSFORM_TEX(input.texcoord, _NoiseTex);
        return output;
    }

    fixed4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed  noise = tex2D(_NoiseTex,input.v2Texcoord1).r;
        half atten = noise - _Time.x * _DissolveSpeed;
        half weight0 = smoothstep(0,_DissolveWidth,atten);
        half weight1 = smoothstep(-_DissolveWidth,0,atten);
            
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord0);

        fixed3 v3FinialColor = lerp(_DissolveColor.rgb,v4RGBColor.rgb,weight0);
        return fixed4(v3FinialColor ,weight1 * v4RGBColor.a);
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
			Cull off
           //ZWrite Off

            CGPROGRAM           
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
			ENDCG
        }
		
   }
}
