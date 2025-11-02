//水面，有实时反射/折射
//参数：
//    _ReflectTex           反射贴图(寻址方式：Clamp)，例如，蓝天白云
//    _WaterBump            水面法线贴图(寻址方式：Repeat)
//    _ShallowWaterColor    浅水颜色
//    _DepthWaterColor      深水颜色、
//    _ReflRefrDistort      反射/折射程度值
//    _ReflectionWeight     反射贴图权重
//    _WaveLength01          x,y,z,w对应0/1波的波长（最好从高频到低频的波）
//    _WaveLength02          x,y    对应2波的波长（最好从高频到低频的波）
//    _Wave01Speed          (x,y)Wave1波速， (z,w)Wave2波速     
//    _Wave02Speed          (x,y)Wave3波速 
Shader "YueChuan/SimpleWater/MediumWater" 
{
	Properties 
	{
	    _ReflectTex ("_Reflect Texture (RGB)", Cube) = "" { TexGen CubeReflect }
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
                 
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				float4 v4Proj: TEXCOORD0;
				float4 v4WPos: TEXCOORD1;
				half4  v2Wave0 : TEXCOORD2;
				half2  v2Wave1 : TEXCOORD3;
				half2  v2Wave2 : TEXCOORD4;
				half2 v2Texcoord : TEXCOORD5;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v4Proj = ComputeScreenPos(output.Position);
                output.v2Wave0.xy = (input.texcoord.xy) * _WaveLength01.xy + fmod(_Time.y * _Wave01Speed.xy, 1);
                output.v2Wave1 = (input.texcoord.xy) * _WaveLength01.zw + fmod(_Time.y * _Wave01Speed.zw, 1);
                output.v2Wave2 = (input.texcoord.xy) * _WaveLength02.xy + fmod(_Time.y * _Wave02Speed.xy, 1);
                output.v2Wave0.zw = output.v4Proj.w;
                
                output.v4WPos = mul(_Object2World, input.vertex);
                output.v2Texcoord = input.texcoord;
                return output;
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {
                half3 incident = normalize(input.v4WPos.xyz - _WorldSpaceCameraPos.xyz);
                half3 v3ReflectDir = normalize(reflect(incident,half3(0,1,0)));
                half3 v3ViewDir = -incident.xzy;

                half3 bumpNormal = BumpNormal(input.v2Wave0.xy,input.v2Wave1.xy,input.v2Wave2.xy);
				half3 vReflectBump = bumpNormal * half3(_ReflRefrDistort.xxx);
				half3 vRefractBump = bumpNormal * half3(_ReflRefrDistort.yyy);
				half4 v4RefractUV = UNITY_PROJ_COORD(input.v4Proj + half4(vRefractBump.xy, 0, 0));
                
                fixed3 v3ReflectColor = texCUBE(_ReflectTex,v3ReflectDir.xyz + vReflectBump);
				//fixed3 v3ReflectColor = texCUBE(_ReflectTex, v3ReflectDir.xyz);
				v3ReflectColor *= v3ReflectColor;
				//v3ReflectColor *= 2.0;
				//v3ReflectColor = v3ReflectColor.g;

                half fresnel = 0;
                fixed3 v3WaterColor = 0;
                WaterColorMH(v4RefractUV,input.v2Texcoord,vReflectBump,vRefractBump,v3ViewDir,input.v2Wave0.w,fresnel,v3WaterColor);
                fixed3 v3Final = fresnel* v3ReflectColor * _ReflectOffsetWeight + (1 - fresnel)*v3WaterColor;
				//fixed3 v3Final = fresnel* v3ReflectColor * _ReflectOffsetWeight + v3WaterColor;
				//return fixed4(v3WaterColor, 1.0);
				return fixed4(v3Final.rgb, 1.0);
				return fixed4(v3ReflectColor*_ReflectOffsetWeight, 1.0);
                return fresnel;
				
            }
            ENDCG
        }
    }
}
