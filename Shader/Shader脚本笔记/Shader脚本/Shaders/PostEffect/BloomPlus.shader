Shader "YueChuan/PostEffect/BloomPlus"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
            
    uniform sampler2D _MainTex;

	uniform half _IntensityOffset;
	uniform half _IntensityScale;

	uniform fixed4 _Color;
    
    struct VS_OUTPUT
    {
        float4 pos : SV_POSITION;
        half2 uv : Texcoord0;
    };
    
    VS_OUTPUT MainVS(appdata_base input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;

        output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
        output.uv = input.vertex.xy;

        return output;
    }
    
    fixed4 BrightnessPS(VS_OUTPUT input) : COLOR
    {
    	fixed4 rgba = tex2D(_MainTex,input.uv);
	    fixed4 old_intensity = dot(rgba.rgb, fixed3(0.3, 0.59, 0.11));

		fixed4 new_intensity = (old_intensity + _IntensityOffset) * _IntensityScale;
		
		return fixed4(rgba.rgb * new_intensity * rgba.a * _Color.rgb,1.0);
    }

	fixed4 AddStuffPS(VS_OUTPUT input) : COLOR
	{
		return tex2D(_MainTex, input.uv);
	}
    
    ENDCG
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		Lighting Off
		ZWrite Off
		AlphaTest Off
		Pass
		{
			Name "Brightness"
			Stencil
		    {
			    Ref 3
			    Comp equal
			    Pass Keep
		    }
			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment BrightnessPS
            #pragma target 2.0
           
            ENDCG
		}
		Pass
		{
			Name "Add"
			Blend one one
			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment AddStuffPS
            #pragma target 2.0

			ENDCG
		}
	}
}
