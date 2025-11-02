Shader "YueChuan/Character/Dissolve" 
{
Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_DissolveColor ("Dissolve Color", Color) = (1.0,0.0,0.0,1.0)
		_MainTex ("Base (RGB)", 2D) = "White" {}
		_NoiseTex ("Noise", 2D) = "White" {}
		
		_EmissionAmount ("Emissive Amount", Float) = 1.0
		_DissolveSpeed ("Dissolve Speed", Range(-1,2)) = 0.0
		_DissolveWidth ("Dissolve Width", Range(0,1)) = 0.02
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "CharacterInfo.cginc"
   
    uniform sampler2D _MainTex;
    uniform sampler2D _NoiseTex;
    uniform half4 _MainTex_ST;
    
    uniform fixed4 _DissolveColor;
    uniform half _DissolveSpeed;
    uniform half _DissolveWidth;
   
        
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
        fixed  noise = tex2D(_NoiseTex,input.v2Texcoord).r;
        half atten = noise - _DissolveSpeed;
        half weight0 = smoothstep(0,_DissolveWidth,atten);
        half weight1 = smoothstep(-_DissolveWidth,0,atten);
            
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
        fixed4 v4Color = CharacterColor(v4RGBColor,fixed4(0,0,0,0));

        fixed3 v3FinialColor = lerp(_DissolveColor.rgb,v4Color.rgb,weight0);
        return fixed4(v3FinialColor ,weight1 * v4Color.a);
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
			Cull back
           //ZWrite Off

            CGPROGRAM           
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
			ENDCG
        }
		
   }
}
