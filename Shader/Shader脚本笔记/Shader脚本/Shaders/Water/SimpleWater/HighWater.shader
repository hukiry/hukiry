Shader "YueChuan/SimpleWater/HighWater" 
{
	Properties 
	{
	    _ReflectTex2D ("_Reflect Texture (RGB)", 2D) = "black" {}
	    _RefractTex ("Refract Texture (RGB)", 2D) = "black" {}
	    _TerrainOutlineTex("Terrain Outline", 2D) = "white" {}
	}
    SubShader 
    {
        Tags { "Queue" = "Transparent"}
        //Fog { Mode off }
		Lighting Off
        Pass 
        {
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 3.0
           
            #include "UnityCG.cginc"
            #include "WaterInfo.cginc"
            
            sampler2D _ReflectTex2D;

            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				float4 v4Proj: TEXCOORD0;
				float4 v4WPos: TEXCOORD1;
				half4  v4Wave0 : TEXCOORD2;
				half2  v2Wave1 : TEXCOORD3;
				half2  v2Wave2 : TEXCOORD4;
				half2 v2Texcoord : TEXCOORD5;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v4Proj = ComputeScreenPos(output.Position);
                output.v4Wave0.xy = (input.texcoord.xy) * _WaveLength01.xy + fmod(_Time.y * _Wave01Speed.xy, 1);
                output.v2Wave1 = (input.texcoord.xy) * _WaveLength01.zw + fmod(_Time.y * _Wave01Speed.zw, 1);
                output.v2Wave2 = (input.texcoord.xy) * _WaveLength02.xy + fmod(_Time.y * _Wave02Speed.xy, 1);
                output.v4Wave0.zw = output.v4Proj.w;
               
                output.v4WPos = mul(_Object2World, input.vertex);
                output.v2Texcoord = input.texcoord;
                
                return output;
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {
                half3 v3View = _WorldSpaceCameraPos.xyz - input.v4WPos.xyz;
                half  distToCamera = length(v3View);
                half3 v3ViewDir = v3View.xzy/distToCamera;

                half3 bumpNormal = BumpNormal(input.v4Wave0.xy,input.v2Wave1.xy,input.v2Wave2.xy);
                half3 vReflectBump =  bumpNormal * half3(_ReflRefrDistort.xxx);
                half3 vRefractBump =  bumpNormal * half3(_ReflRefrDistort.yyy);

				half4 v4RefractUV = UNITY_PROJ_COORD(input.v4Proj + half4(vRefractBump.xy,0,0));
				half4 v4ReflectUV = UNITY_PROJ_COORD(input.v4Proj + half4(vReflectBump.xy * 3, 0, 0));

                fixed3 v3ReflectColor = tex2Dproj(_ReflectTex2D , v4ReflectUV);

				v3ReflectColor *= v3ReflectColor;
				//v3ReflectColor *= 1.5;
                
                half fresnel = 0;
                fixed3 v3WaterColor = 0;
                WaterColorMH(v4RefractUV,input.v2Texcoord,vReflectBump,vRefractBump,v3ViewDir,input.v4Wave0.w,fresnel,v3WaterColor);
				fixed3 v3Final = fresnel * v3ReflectColor + v3WaterColor;

				//fixed3 v3Final = fresnel * v3ReflectColor + (1 - fresnel) * v3WaterColor;
			//	return fresnel;
				return fixed4(v3Final.rgb,1.0);
				//return fixed4(v3ReflectColor,1.0);
            }
            ENDCG
        }
    }
}
