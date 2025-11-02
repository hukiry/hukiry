//最简单的水面，没有实时折射和反射
//参数：
//    _ReflectTex           反射贴图(寻址方式：Clamp)，例如，蓝天白云
//    _WaterBump            水面法线贴图(寻址方式：Repeat)
//    _ShallowWaterColor    浅水颜色
//    _DepthWaterColor      深水颜色、
//    _ReflRefrDistort      反射/折射程度值
//    _ReflectionWeight     反射贴图权重
//    _WaveLength01          x,y,z,w对应01波的波长（最好从高频到低频的波）
//    _WaveLength02          x,y对应2波的波长（最好从高频到低频的波）
//    _Wave01Speed          (x,y)Wave1波速， (z,w)Wave2波速     
//    _Wave02Speed          (x,y)Wave3波速 
Shader "YueChuan/SimpleWater/LowWater" 
{
    Properties 
	{
	    _ReflectTex ("_Reflect Texture (RGB)", Cube) = "" { TexGen CubeReflect }	
		_WaterBump ("Water Bump)", 2D) = "black" {}
        _TerrainOutlineTex("Terrain Outline", 2D) = "white" {}
	    _WaterColor ("Water Color", Color) = (0.5,0.5,0.5,0.5)
	    _ShallowWaterColor ("Shallow Water Color", Color) = (0.5,0.5,0.5,0.5)
	    _DepthWaterColor ("Depth Water Color", Color) = (0.5,0.5,0.5,0.5)
		_ReflRefrDistort("ReflRefr Distort",Vector) = (0.1,0.1,0.01,0.01) 
		_ReflectOffsetWeight ("Reflection Weight", Range(0.0,1.0)) = 1.0
		_FresnelOffset ("Fresnel Offset", Range(0.0,1.0)) = 0.0
		_WaveLength01("Wave Length01",Vector) = (0.0,0.0,0.0,0.0) 
		_WaveLength02("Wave Length02",Vector) = (0.0,0.0,0.0,0.0) 
		_Wave01Speed("Wave01 Speed",Vector) = (0.0,0.0,0.0,0.0) 
		_Wave02Speed("Wave02 Speed",Vector) = (0.0,0.0,0.0,0.0) 
		
		_WaterDepthScale("Water Depth Scale",Float) = 1.0
		_WaterDepthOffset("Water Depth Offset",Float) = 0.0
	}
	SubShader
	{
            Tags { "Queue" = "Transparent"}
		    LOD 200
		   // Fog { Mode off }
		    Lighting Off
		    pass 
            {
			     Name "TransparentLowWater"
		         Blend SrcAlpha OneMinusSrcAlpha
                 CGPROGRAM

                 #pragma vertex VS_Main
                 #pragma fragment PS_TransparentLowWater
                 #pragma target 2.0
           
                 ENDCG
            }
     }
            CGINCLUDE
            #include "UnityCG.cginc"
            #include "WaterInfo.cginc"
                 
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
			    float4 v4WPos : TEXCOORD0;
				half2 v2Texcoord : TEXCOORD1;
				half2  v2Wave0 : TEXCOORD2;
				half2  v2Wave1 : TEXCOORD3;
				half2  v2Wave2 : TEXCOORD4;
            };

            VS_OUTPUT VS_Main(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v4WPos = mul(_Object2World, input.vertex);
                output.v2Texcoord = input.texcoord;
                
                output.v2Wave0 = input.texcoord.xy * _WaveLength01.xy + fmod(_Time.y * _Wave01Speed.xy, 1);
                output.v2Wave1 = input.texcoord.xy * _WaveLength01.zw + fmod(_Time.y * _Wave01Speed.zw, 1);
                output.v2Wave2 = input.texcoord.xy * _WaveLength02.xy + fmod(_Time.y * _Wave02Speed.xy, 1);
                
                return output;
            }
            
            fixed4 PS_TransparentLowWater(VS_OUTPUT input) : COLOR 
            {
                half3 incident = normalize(input.v4WPos.xyz - _WorldSpaceCameraPos.xyz);
                half3 v3ReflectDir = normalize(reflect(incident,half3(0,1,0)));
                half3 v3ViewDir = -incident.xzy;
            
                half3 bumpNormal = BumpNormal(input.v2Wave0.xy,input.v2Wave1.xy,input.v2Wave2.xy);           
                half3 vReflectBump = bumpNormal.xyz * half3(_ReflRefrDistort.zzz);
                
                fixed3 v3ReflectColor = texCUBE(_ReflectTex, v3ReflectDir + vReflectBump);

                fixed4 outLineMask = tex2D(_TerrainOutlineTex, input.v2Texcoord);
                
                half deepValue = (1 - outLineMask.r) * _WaterDepthScale + _WaterDepthOffset;

                half NdotL  = max(dot(v3ViewDir, vReflectBump),0);
                half facing = 1.0 - NdotL;
                half fresnel = Fresnel(NdotL,_FresnelOffset,5);
                fixed3 v3WaterColor = lerp(_ShallowWaterColor,_DepthWaterColor,facing);
                
				fixed3 color = v3ReflectColor * _ReflectOffsetWeight + v3WaterColor;
                return fixed4(color,fresnel + deepValue);
                
                //return deepValue;
               //return fixed4(v3FoamTex,1.0); 
               //return fresnel;
            }
            ENDCG
}
