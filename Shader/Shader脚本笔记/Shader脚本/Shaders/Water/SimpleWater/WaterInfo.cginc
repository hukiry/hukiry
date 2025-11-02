#ifndef WATERINFO_INCLUDED
#define WATERINFO_INCLUDED

samplerCUBE _ReflectTex;
sampler2D _RefractTex;
sampler2D _WaterBump;
sampler2D _TerrainOutlineTex;
                                      
uniform fixed4 _ShallowWaterColor;
uniform fixed4 _DepthWaterColor;
uniform half4 _ReflRefrDistort;
uniform half  _FresnelOffset;
uniform half  _ReflectOffsetWeight;
uniform half4 _WaveLength01;
uniform half4 _WaveLength02;
uniform half4 _Wave01Speed;
uniform half4 _Wave02Speed;
uniform half  _ViewDistanceScale;
uniform half  _WaterDepthScale;
uniform half  _WaterDepthOffset;


half Fresnel(half NdotL,half frenelBias,half fresnelPow)
{
    half facing = (1.0 - NdotL);
    return max(frenelBias + (1.0 - frenelBias) * pow(facing,fresnelPow), 0.0);
}

float3x3 GetTangentSpaceBasis(float4 T, float3 N)
{
    float3x3 objToTangentSpace;
    objToTangentSpace[0]=T;           // tangent
    objToTangentSpace[1]=cross(N,T.xyz) * T.w; // binormal
    objToTangentSpace[2]=N;           // normal  
   
   return objToTangentSpace;
}

fixed3 BumpNormal(half2 v2Wave0,half2 v2Wave1,half2 v2Wave2)
{
    fixed4 bumpNormal0 = (tex2D(_WaterBump,v2Wave0));
    fixed4 bumpNormal1 = (tex2D(_WaterBump,v2Wave1));
    fixed4 bumpNormal2 = (tex2D(_WaterBump,v2Wave2));
    
    return normalize(UnpackNormal(bumpNormal0) + UnpackNormal(bumpNormal1) + UnpackNormal(bumpNormal2));
}

void WaterColorMH(half4 v4RefractUV,
                  half2 v2Texcoord,
                  half3 vReflectBump,
                  half3 vRefractBump,
                  half3 v3ViewDir,
                  half w,
                  out half fresnel,
                  out fixed3 v3WaterColor)
{
    fixed4 outLineMask = tex2D(_TerrainOutlineTex, v2Texcoord);   
    half deepValue = saturate(outLineMask.r * _WaterDepthScale + _WaterDepthOffset);
    
    fixed3 v3RefractColor = tex2Dproj(_RefractTex, v4RefractUV) * deepValue;
    
    half fDistScale = saturate(_ViewDistanceScale/w);
	fixed3 waterColor = lerp(_DepthWaterColor, _ShallowWaterColor, fDistScale);
	waterColor *= v3RefractColor;

    //fixed3 WaterDeepColor = lerp(_DepthWaterColor,v3RefractColor,fDistScale);
    
    half NdotL  = max(dot(v3ViewDir, vReflectBump),0);
    half facing = 1.0 - NdotL;
    fresnel = max(0,Fresnel(NdotL,_FresnelOffset,5));

	//v3WaterColor = v3RefractColor * waterColor;
	//v3WaterColor = waterColor * v3RefractColor;
	//v3WaterColor = lerp(fixed3(1,0,0), fixed3(0,1,0), facing);
	//v3WaterColor = lerp(v3RefractColor, waterColor * v3RefractColor, facing) * deepValue;
    v3WaterColor = lerp(v3RefractColor,waterColor,facing) * deepValue;
	//v3WaterColor = v3RefractColor * deepValue;
	//v3WaterColor += (WaterDeepColor * (1- fresnel));
}



#endif

