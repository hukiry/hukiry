//第四步
Shader "YueChuan/InteractWater/RenderWater" 
{
    Properties 
	{
		_RefractTex ("Refract Tex", 2D) = "black" {}
		_WaterNormal ("Water Normal Tex", 2D) = "black" {}
		_WaterShapeTex ("Water Shape Tex", 2D) = "white" {}
	    _ReflectTex ("_Reflect Texture (RGB)", Cube) = "" { TexGen CubeReflect }
		_DistortLevel("Water Distort Level ", Float) = 0.01
	}
    SubShader 
    {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent"}
        //Fog { Mode off }
		Lighting Off

        // Render the object with the texture generated above, and invert it's colors
        Pass 
        {
		    Blend SrcAlpha OneMinusSrcAlpha
        
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _WaterNormal : register(s0);
            uniform sampler2D _RefractTex : register(s1);
            uniform sampler2D _WaterShapeTex : register(s2);
            uniform samplerCUBE _ReflectTex : register(s3);
        
            uniform float4x4 g_matForceViewProj;
            uniform half  _DistortLevel;
            uniform half  _ViewDistanceScale;
            
            uniform fixed4 _ShallowWaterColor;
            uniform fixed4 _DepthWaterColor;
            uniform fixed4 _WaterColor;
        
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				float4 v4ProjMC: TEXCOORD0;
				float4 v4ProjSC : TEXCOORD1;
				half4  v4WPos : TEXCOORD2;
				half3  v2Texcoord : TEXCOORD3;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v4ProjMC = ComputeScreenPos(output.Position);
                output.v4WPos = mul(_Object2World, input.vertex);
                
			    float4x4 matSCMVP= mul (g_matForceViewProj,_Object2World);
                output.v4ProjSC = mul(matSCMVP, input.vertex);
                
                output.v2Texcoord = half3(input.texcoord.xy,output.Position.w);
                return output;
            }
            
            half Fresnel(half NdotL,half frenelBias,half fresnelPow)
            {
              half facing = (1.0 - NdotL);
              return max(frenelBias + (1.0 - frenelBias) * pow(facing,fresnelPow), 0.0);
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {   
                half3 incident = normalize(input.v4WPos.xyz - _WorldSpaceCameraPos.xyz);
                half3 v3ReflectDir = normalize(reflect(incident,half3(0,1,0)));
                half3 v3ViewDir = -incident.xzy;
                
                half2 v2SpringCameraUV = 0.5 * input.v4ProjSC.xy/input.v4ProjSC.w + 0.5;
                #if UNITY_UV_STARTS_AT_TOP
                v2SpringCameraUV.y = 1 - v2SpringCameraUV.y;
                #endif
                
	            half waterShape = tex2D(_WaterShapeTex, input.v2Texcoord).r;
                fixed3 v3ReflectColor = texCUBE(_ReflectTex,v3ReflectDir).xyz;
                
	            fixed4 normalmap = tex2D(_WaterNormal, v2SpringCameraUV);
	            half3 normal = (normalmap.rgb - 0.5f) * 2.0f;
		        half4 distortOffset = half4(normal.xz * _DistortLevel, 0, 0);
	            fixed3 v3RefractColor = tex2Dproj(_RefractTex, UNITY_PROJ_COORD(input.v4ProjMC + distortOffset)).rgb;
	            
	            half fDistScale = saturate(_ViewDistanceScale/input.v2Texcoord.z);
                fixed3 v3WaterDeepColor = lerp(_DepthWaterColor,v3RefractColor,fDistScale);
	          
	            half NdotL  = max(dot(v3ViewDir.xyz,normal),0);
                half facing = 1.0 - NdotL;
                half fresnel = max(0,Fresnel(NdotL,0,5));
                
                fixed3 v3WaterColor = lerp(_ShallowWaterColor,v3WaterDeepColor,facing);
                fixed3 v3Final = fresnel * v3ReflectColor + v3WaterColor;
				return fixed4(v3Final * _WaterColor.rgb,waterShape);
	            //return fresnel;
	            //return fixed4(v3RefractColor,waterShape);
            }
            ENDCG
        }
    }
}
