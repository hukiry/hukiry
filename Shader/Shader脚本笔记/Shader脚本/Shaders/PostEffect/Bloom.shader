Shader "YueChuan/PostEffect/Bloom"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
            
    sampler2D _MainTex;
    sampler2D _bloomTexture;
    float _threshhold;
    float _bloomIntensity;
    float4 _bloomColor;

	float4 _DownScaleOffsets01;
	float4 _DownScaleOffsets23;
    
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

	float4 Downscale2x2(VS_OUTPUT input) : COLOR 
	{
		half3 downsampledColor = half3(0,0,0);
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.zw).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.zw).rgb;
		downsampledColor *= 0.25f;
		return float4(downsampledColor, 1.0f);
	}

    float4 BrightFilterPS(VS_OUTPUT input) : COLOR 
    {
		half3 downsampledColor = half3(0,0,0);
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets01.zw).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.xy).rgb;
		downsampledColor += tex2D(_MainTex, input.uv + _DownScaleOffsets23.zw).rgb;
		downsampledColor *= 0.25f;

        downsampledColor.rgb = max(half3(0, 0, 0), downsampledColor.rgb - half3(_threshhold, _threshhold, _threshhold));
        downsampledColor = downsampledColor * _bloomColor;

        float4 color = float4(downsampledColor, 1.0f);
        return saturate(color);
    }

    float3 GammaCorrect(float3 color, float gamma)
    {
        float r = pow(color.r, gamma);
        float g = pow(color.g, gamma);
        float b = pow(color.b, gamma);
        return float3(r, g, b);
    }

    float3 HDRToLDR(float3 color, float midGray, float avgLum)
    {
        color.rgb *= midGray / (avgLum + 0.001f);
        color.rgb /= (1.0f + color);
        return color;
    }
    
    float4 AddStuffPS(VS_OUTPUT input) : COLOR
    {
        half4 screenColor = tex2D(_MainTex, input.uv);
        half4 bloomColor = tex2D(_bloomTexture, input.uv);

        half screenLum = Luminance(screenColor.rgb);
        float t = saturate((screenLum - 0.4f) / (1 - 0.4f));
        float bloomMultiply = lerp(_bloomIntensity, 0, t);
        //float bloomMultiply = _bloomIntensity;
        float4 result = screenColor + bloomColor * bloomMultiply;

        //result.rgb = HDRToLDR(result.rgb, 0.6f, 0.7f);
        return result;
    }
    
    ENDCG
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			CGPROGRAM

            #pragma vertex VS
            #pragma fragment Downscale2x2
            #pragma target 2.0
           
            ENDCG
		}

		Pass 
        {
        	Name "BrightFilter"
        
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment BrightFilterPS
            #pragma target 2.0
           
            ENDCG
        }
        
        pass
        {
        	Name "AddStuff"
        
        	//Blend One One
        	
        	CGPROGRAM

            #pragma vertex VS
            #pragma fragment AddStuffPS
            #pragma target 2.0
           
            ENDCG
        }
	}
}
