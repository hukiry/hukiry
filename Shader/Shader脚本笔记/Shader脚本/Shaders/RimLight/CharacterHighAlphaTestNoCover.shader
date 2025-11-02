Shader "YueChuan/Character/CharacterHighAlphaTestNoCover" 
{
    Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_RimColor ("Edge Color", Color) = (1.0,1.0,1.0,1.0)
		
		_AlphaTestValue ("AlphaTest Value", Range(0.0,1.0)) = 0.6
		_MainTex ("Base (RGB)", 2D) = "White" {}
		_GrayAmount ("Gray Amount", Float) = 0.0
		_EmissionAmount ("Emissive Amount", Float) = 1.0
		[HideInInspector]_AdditionColor ("Addition Color", Color) = (1.0,1.0,1.0,1.0)
	}

	CGINCLUDE
    #include "UnityCG.cginc"
	#include "CharacterInfo.cginc"
   
    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;
    
    uniform half _IsRimLight;
    uniform half _AlphaTestValue;
    
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
        fixed4 v4RimColor : TEXCOORD1;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
        output.v4RimColor = 0;
        if (_IsRimLight)
        {
            float4 v4WPos = mul(_Object2World, input.vertex);
            float3 v3WNormal = normalize(mul((float3x3)_Object2World, input.normal));
            float3 vEyeDir = normalize(_WorldSpaceCameraPos.xyz - v4WPos.xyz);
            output.v4RimColor = RimLight(vEyeDir,v3WNormal,0.4,_RimColor) * _Attenuation; 
        }
        
        return output;
    }

    fixed4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed4 v4RGBColor = tex2D(_MainTex,input.v2Texcoord);
        fixed4 v4Color = CharacterColor(v4RGBColor,input.v4RimColor);
		if (v4Color.a < _AlphaTestValue) discard;
        return v4Color;
    }
    ENDCG

 SubShader
	{
		Tags {"RenderType"="Opaque" "Queue"="Geometry+400" "LightMode" = "Vertex"}
		LOD 200

	    Pass 
        {
			ZTest Less
            Cull Back 

            CGPROGRAM           
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
			ENDCG
        }
   }
}
