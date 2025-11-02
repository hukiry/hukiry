#ifndef CHARACTERINFO_INCLUDED
#define CHARACTERINFO_INCLUDED

uniform half _EmissionAmount;
uniform half _GrayAmount;
uniform half _Attenuation;
uniform fixed4 _Color;
uniform fixed4 _AdditionColor;
uniform fixed4 _RimColor;

uniform half _Shininess;
uniform fixed4  _SpecColor;
uniform fixed4 _Emission;
uniform fixed4 _SideColor;

half ShadeSpecLight(half3 lightDir, half3 viewDir,half3 normal,half atten, half power)
{
      half3 h = normalize (lightDir + viewDir);
      half nh = max (0, dot (normal, h));
      half spec = pow (nh, power);
      half c;
      c = spec * atten;
      return c;
}
            
fixed3 ShadeLights (float4 vertex, float3 normal)
{
	   half3 viewpos = mul (UNITY_MATRIX_MV, vertex).xyz;
	   half3 viewN = mul ((float3x3)UNITY_MATRIX_IT_MV, normal);
	   fixed3 diffColor = 0;
	   fixed3 specColor = 0;      
	   half3 viewDir = -viewpos;
  //   for (int i = 0; i < 4; i++) 
	// {
		      half3 toLight = unity_LightPosition[0].xyz - viewpos.xyz * unity_LightPosition[0].w;
		      half lengthSq = dot(toLight, toLight);
		      half atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);
		      half diff = max (0, dot (viewN, normalize(toLight)));
		      diffColor += unity_LightColor[0].rgb * (diff * atten);
		      specColor += ShadeSpecLight(toLight,viewDir,viewN, atten, 32.0f);
   //  } 
	   return UNITY_LIGHTMODEL_AMBIENT.xyz + diffColor * _Color.rgb + specColor * _SpecColor.rgb + _Emission.rgb;
}

fixed4 RimLight(half3 vEyeDir,half3 v3WNormal,float exponent,fixed4 color)
{
   return pow(1.0 - dot(vEyeDir,v3WNormal),exponent) * color;
}

half _RimLight(half3 vEyeDir,half3 v3WNormal,float exponent)
{
   return pow(1.0 - dot(vEyeDir,v3WNormal),exponent);
}

half SideLine(half3 viewEyeDir, half3 viewNormal)
{
	half d = saturate(1 - dot(viewEyeDir, viewNormal));
	if (d < 0.5)
		d = 0;

	return d;
}

fixed4 SideLight(half3 viewEyeDir, half3 viewNormal, half3 lightDir)
{
    // unity的View Space使用的是右手坐标系，也就是z的正方向指向摄像机而不是屏幕内
    half diffuse = max(0, dot(lightDir, viewNormal));
    //diffuse = max(0, (diffuse+1)/2);
    diffuse = max(0, diffuse);
    diffuse = smoothstep(0, 1, diffuse);
    //diffuse = floor(diffuse * 3) / 3;

    if (diffuse < 0.4f)
        diffuse = 0.80f;
    /*else if (diffuse < 0.8f)
        diffuse = 1.0f;*/
    else
        diffuse = 1.0f;

    //half spec = ShadeSpecLight(lightDir, viewEyeDir, viewNormal, 0.5, 6.0f);
    //spec = floor(spec * 2) / 2;
    half spec = 0;

    fixed3 lightColor = float3(1, 1, 1) * 1.1;
    fixed4 result = float4((diffuse + spec)* lightColor, 1);
    return result;
}

fixed4 CharacterColor(fixed4 v4RGBColor,fixed4 v4RimColor)
{
	fixed4 v4Emission = v4RGBColor * _Color * _EmissionAmount;
    fixed4 v4BaseColor = v4RGBColor * _Color;
    fixed3 v3GrayColor = dot(v4RGBColor.rgb,fixed3(0.299,0.587,0.114)) * _AdditionColor.rgb;
	fixed3 v3FinialColor = UNITY_LIGHTMODEL_AMBIENT.xyz * lerp(v4BaseColor.rgb,v3GrayColor,_GrayAmount) + v4RimColor.rgb + 
						lerp(v4Emission.rgb,v3GrayColor*_EmissionAmount,_GrayAmount);
								
    return fixed4(v3FinialColor,v4BaseColor.a);
}



#endif


