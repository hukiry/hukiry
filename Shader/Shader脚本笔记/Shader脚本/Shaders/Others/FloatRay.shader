Shader "YueChuan/Others/FloatRay" 
{
    Properties 
	{
	    _MainTex ("Base Texture (RGB)", 2D) = "white" {}
	    _ReflectTex ("_Reflect Texture (RGB)", Cube) = "" { TexGen CubeReflect }
	    _FloatRayTex0 ("FloatRay Texture0 (RGB)", 2D) = "black" {}
	    _FloatRayTex1 ("FloatRay Texture1 (RGB)", 2D) = "black" {}
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_ColorWeight ("Color Weight(x * FloatLight,y * Reflection,z * MainTex) Range(0,1]", Vector) = (0.8,0.3,0.7,1.0)
	}
    SubShader 
    {
        // Draw ourselves after all opaque geometry
		Tags { "RenderType"="Opaque" }
        //Fog { Mode off }
		Lighting Off
        Pass 
        {
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            sampler2D _MainTex : register(s0);
            samplerCUBE _ReflectTex : register(s1);
            sampler2D _FloatRayTex0 : register(s2);
            sampler2D _FloatRayTex1 : register(s3);
            
            uniform half4 _MainTex_ST;
            uniform half4 _FloatRayTex0_ST;
            uniform half4 _FloatRayTex1_ST;
            uniform fixed4 _Color;
            uniform half4 _ColorWeight;
                 
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				half2 v2MainUV: TEXCOORD0;
				half3 v3ReflectUV : TEXCOORD1;
				half2 v2FloatRayUV0: TEXCOORD2;
				half2 v2FloatRayUV1: TEXCOORD3;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                half3 v3WNormal = mul((float3x3)_Object2World, input.normal);
                half4 v4WPos = mul(_Object2World, input.vertex);
                
                output.v2MainUV = TRANSFORM_TEX(input.texcoord, _MainTex);
                output.v3ReflectUV = reflect(normalize(v4WPos.xyz - _WorldSpaceCameraPos.xyz),v3WNormal);
                
                output.v2FloatRayUV0 = TRANSFORM_TEX(input.texcoord, _FloatRayTex0) + half2(0,_Time.x * 20);
                output.v2FloatRayUV1 = TRANSFORM_TEX(input.texcoord, _FloatRayTex1) + half2(_Time.x * 15,0);
                
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                fixed4 v4MainTex = tex2D(_MainTex,input.v2MainUV);
                fixed4 v4ReflectTex = texCUBE(_ReflectTex,input.v3ReflectUV);
                fixed4 v4FloatRayTex = (tex2D(_FloatRayTex0,input.v2FloatRayUV0) + tex2D(_FloatRayTex1,input.v2FloatRayUV1)) * 0.5;
				return v4FloatRayTex * _ColorWeight.x + v4ReflectTex * _ColorWeight.y + v4MainTex * _ColorWeight.z;
            }
            ENDCG
        }
    }
}
