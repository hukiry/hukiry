Shader "YueChuan/RimLight/RimLightTwoPass" 
{
    Properties 
	{
		_RimColor ("Rim Color", Color) = (1.0,1.0,1.0,1.0)
		[HideInInspector]_Attenuation("Attenuation", Float) = 0.0
	}
    SubShader
	{
		Tags {"RenderType"="Opaque"}
		LOD 200
	    Pass 
        {
			Blend one one
            CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
   
            uniform half4 _RimColor;
            uniform half _Attenuation;
        
            struct VS_OUTPUT
            {
                float4 v4Position : SV_POSITION;
                half4 v4RimColor : TEXCOORD0;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
            
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
                half4 v4WPos = mul(_Object2World, input.vertex);
                half3 v3WNormal = mul((float3x3)_Object2World, input.normal);
                half3 vEyeDir = normalize(_WorldSpaceCameraPos.xyz - v4WPos.xyz);
                output.v4RimColor = (1.0 - dot(vEyeDir,v3WNormal)) * _RimColor * sin(_Attenuation);
                
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                return input.v4RimColor;
            }
            ENDCG
        }
   }
}
