Shader "YueChuan/PostEffect/Lightshaft"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
            
    sampler2D _MainTex : register(s0);
    sampler2D _CameraDepthTexture : register(s1);
    sampler2D _LightShaft;

	float4 _SunDirScreen = float4(0.5, 0.8, 0, 0);
	float4 _SunColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
	float _SunOutSize = 0.2f;
	float _SunInnerSize = 0.2f;
	float _Density = 1.0f;
	float _Weight  = 1.0f;
	float _Decay   = 1.0f;
	float _GodRayExposure = 0.29;
	float _WHRatio = 1.0f;

	float4 _DownScaleOffsets01;
	float4 _DownScaleOffsets23;

	//int _NumSamples = 4;
    
    struct VS_OUTPUT
    {
        float4 pos : SV_POSITION;
        float2 uv : Texcoord0;
    };
    
    VS_OUTPUT VS(appdata_base input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.uv = input.texcoord;

        return output;
    }

	float4 PS_DownScale2x2(VS_OUTPUT input) : COLOR 
	{
		half3 downsampledColor = half3(0,0,0);
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.zw).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.zw).rgb;
		downsampledColor *= 0.25f;
		return float4(downsampledColor, 1.0f);
	}

    float4 PS_FilterSun(VS_OUTPUT input) : COLOR 
    {
        float3 sunDirScreen = _SunDirScreen;
#if UNITY_UV_STARTS_AT_TOP
        sunDirScreen.y = 1 - sunDirScreen.y;
#endif

		float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, input.uv);
        d = Linear01Depth(d);
        //return d;

		half3 color = tex2D(_MainTex, input.uv).rgb;
        //return float4(color, 1);

		// 这里的Downsample操作，手机上会非常损耗性能
		// 但是光柱这种效果对图像的稳定性要求很高，这里没有办法，光柱效果只有高配才能开启
		/*half3 downsampledColor = half3(0,0,0);
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.zw).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.zw).rgb;
		downsampledColor *= 0.25f;*/

        //return float4(downsampledColor, 1);
		
		//half luminance = max(dot(downsampledColor, half3(.3f, .59f, .11f)), 6.10352e-5);
		//half adjustedLuminance = max(luminance - 0.5f, 0.0f);
		//half3 bloomColor =  downsampledColor / luminance * adjustedLuminance * 2.0f;

        half3 bloomColor = saturate(color - float3(0.4, 0.4, 0.4));

		float du = input.uv.x - sunDirScreen.xy.x;
		float dv = input.uv.y - sunDirScreen.xy.y;
		du *= _WHRatio;

		float distance = length(float2(du, dv));
		float sunMask = 1.0f - saturate(distance / _SunOutSize);
		bloomColor *= sunMask;

		float realSun = 1.0f - saturate(distance / _SunInnerSize);
        if (realSun > 0.1f)
            realSun = 1.0f;

		float3 sun = _SunColor * realSun;

        bloomColor += sun;

        bloomColor = pow(bloomColor, 1/2.2f);
        
        if (d < 1 || sunDirScreen.z < 0)
            bloomColor = half3(0, 0, 0);
        
        return float4(bloomColor.x, bloomColor.y, bloomColor.z, 1.0f);
    }

	float4 PS_Shaft(VS_OUTPUT input) : COLOR 
	{
		half2 texCoord = input.uv;

        float3 sunDirScreen = _SunDirScreen;
		#if UNITY_UV_STARTS_AT_TOP
        sunDirScreen.y = 1 - sunDirScreen.y;
        #endif

		float2 deltaTexCoord = texCoord - sunDirScreen.xy;
		deltaTexCoord *= 1.0f / 4 * _Density;
		
		// Store initial sample.
		half3 color = tex2D(_MainTex, texCoord);
		//return float4(color, 1.0f);

		// Set up illumination decay factor.
		half illuminationDecay = 1.0f;
		half sumWeight = 1.0f;

		// Evaluate summation from Equation 3 NUM_SAMPLES iterations.
		for (int i = 0; i < 4; i++)
		{
			// Step sample location along ray.
			texCoord -= deltaTexCoord;

			// Retrieve sample at new location.
			half3 sample = tex2D(_MainTex, saturate(texCoord));

			half finalWeight = illuminationDecay * _Weight;
			sumWeight += finalWeight;

			// Apply sample attenuation scale/decay factors.
			sample *= finalWeight;

			// Accumulate combined color.
			color += sample;

			// Update exponential decay factor.
			illuminationDecay *= _Decay;
		}

		color /= sumWeight;
		color = saturate(color);

		// Output final color with a further scale control factor.
		return float4(color, 1.0f);
	}

	float4 PS_Blend(VS_OUTPUT input) : COLOR 
    {
//        float3 sunDirScreen = _SunDirScreen;
//#if UNITY_UV_STARTS_AT_TOP
//        sunDirScreen.y = 1 - sunDirScreen.y;
//#endif

        float3 ray = tex2D(_LightShaft, input.uv);
		float3 srceenColor = tex2D(_MainTex, input.uv);
        //return float4(srceenColor, 1);

		float godRayMultiplier = max(_GodRayExposure, 0.1f);
		ray *= godRayMultiplier;

        //float du = input.uv.x - sunDirScreen.xy.x;
        //float dv = input.uv.y - sunDirScreen.xy.y;
        //du *= _WHRatio;

        //float effectRange = _SunOutSize * 1.5f;
        //float distance = effectRange;
        //if (sunDirScreen.z > 0)
        //    distance = length(float2(du, dv));

        //float sunMask = 1.0f - saturate(distance / effectRange);

        float rayLum = Luminance(ray);
        float3 addColor = srceenColor + ray;

        float contrast = lerp(1.0f, 0.8f, rayLum);
        addColor = pow(addColor, contrast);

        float3 result = lerp(addColor, ray, rayLum);

		return float4(result, 1.0f);
    }
    
    ENDCG
	
	SubShader 
	{
		LOD 200
		pass 
        {
			Name "FilterSun"

        	//Blend SrcAlpha OneMinusSrcAlpha
        
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS_FilterSun
            #pragma target 2.0
           
            ENDCG
        }

		pass 
        {
			Name "Shaft"

        	//Blend SrcAlpha OneMinusSrcAlpha
        
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS_Shaft
            #pragma target 2.0
           
            ENDCG
        }

		pass 
        {
			Name "Blend"

        	//Blend SrcAlpha One
        
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS_Blend
            #pragma target 2.0
           
            ENDCG
        }

		pass
		{
			Name "Downscale2x2"

			CGPROGRAM

            #pragma vertex VS
            #pragma fragment PS_DownScale2x2
            #pragma target 2.0
           
            ENDCG
		}
	}
}
