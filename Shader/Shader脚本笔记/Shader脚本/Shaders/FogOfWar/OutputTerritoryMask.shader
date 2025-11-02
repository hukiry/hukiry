Shader "YueChuan/FogOfWar/OutputTerritoryMask" 
{
	CGINCLUDE
	#include "UnityCG.cginc"

	uniform fixed4 _CityColor;
	uniform half _HasExploredFogDensity;
	uniform half4 _TerritoryTexSizeInverse;
	uniform sampler2D _TerritoryTex;

	uniform half4 _ViewCenter;
	uniform half  _BufferAspect;
	uniform half  _BrushSize;
	uniform sampler2D _NoiseTex;
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        half2 v2Texcoord : TEXCOORD0;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
            
        VS_OUTPUT output = (VS_OUTPUT)0;
        output.v4Position = mul(UNITY_MATRIX_MVP, input.vertex);
        output.v2Texcoord = input.texcoord;
        return output;
    }

    fixed4 OutputGrayTerrPS(VS_OUTPUT input) : COLOR 
    {
		fixed3 cityColor = tex2D(_TerritoryTex, input.v2Texcoord).rgb;
	    half mask = 1;
     	if (abs(cityColor.r - _CityColor.r) < 0.01
		 && abs(cityColor.g - _CityColor.g) < 0.01
		 && abs(cityColor.b - _CityColor.b) < 0.01)
	    {
		    mask = _HasExploredFogDensity;
	    }
        return mask;
    }

	half ThirdSplineInterpolate(half a, half b, half t)
	{
		half f = t * t * (-2 * t + 3);
		return a * (1 - f) + b * f;
	}

	fixed4 OutputGrayTerrWithAnimationPS(VS_OUTPUT input) : COLOR
	{
		fixed noise = tex2D(_NoiseTex,input.v2Texcoord).r;
	    fixed mask = tex2D(_TerritoryTex, input.v2Texcoord).r;

    	half2 AB = half2(_BrushSize, _BrushSize * _BufferAspect) * noise;
	    half M = ((input.v2Texcoord.x - _ViewCenter.x) * (input.v2Texcoord.x - _ViewCenter.x)) / (AB.x * AB.x);
	    half S = ((input.v2Texcoord.y - _ViewCenter.y) * (input.v2Texcoord.y - _ViewCenter.y)) / (AB.y * AB.y);
	    half dist = M + S;

	    half t = saturate((dist - (AB.x - _ViewCenter.w)) / (2.0 * _ViewCenter.w));
	    half alpha = ThirdSplineInterpolate(0, _HasExploredFogDensity,t);
	    return max(alpha,mask);
	}

    //水平方向膨胀(此时_TerritoryTex经过OutputGrayTerrPS已经变成了灰度图)
	fixed4 HorizontalDilation7x7PS(VS_OUTPUT input) : COLOR
	{
		fixed color = 0;
	    half2 ScreenParams = _TerritoryTexSizeInverse.xy;
		
		half blurOffset[6] = {-3 ,-2,-1,1,2,3};
		fixed value0 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(blurOffset[0] * ScreenParams.x,0)).r;
		fixed value1 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(blurOffset[1] * ScreenParams.x, 0)).r;
		fixed value2 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(blurOffset[2] * ScreenParams.x, 0)).r;
		fixed value3 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(blurOffset[3] * ScreenParams.x, 0)).r;
		fixed value4 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(blurOffset[4] * ScreenParams.x, 0)).r;
		fixed value5 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(blurOffset[5] * ScreenParams.x, 0)).r;
		if (value0 > 0.0f)
			color = value0;
		if (value1 > 0.0f)
			color = value1;
		if (value2 > 0.0f)
			color = value2;
		if (value3 > 0.0f)
			color = value3;
		if (value4 > 0.0f)
			color = value4;
		if (value5 > 0.0f)
			color = value5;
	    return 1 - color;
	}
	
	//垂直方向膨胀
	fixed4 VerticalDilation7x7PS(VS_OUTPUT input) : COLOR
	{
		fixed color = 0;
	    half2 ScreenParams = _TerritoryTexSizeInverse.xy;
		
		half blurOffset[6] = { -3 ,-2,-1,1,2,3 };
	    fixed value0 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(0,blurOffset[0] * ScreenParams.y)).r;
	    fixed value1 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(0,blurOffset[1] * ScreenParams.y)).r;
		fixed value2 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(0, blurOffset[2] * ScreenParams.y)).r;
		fixed value3 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(0, blurOffset[3] * ScreenParams.y)).r;
		fixed value4 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(0, blurOffset[4] * ScreenParams.y)).r;
		fixed value5 = 1 - tex2D(_TerritoryTex, input.v2Texcoord + half2(0, blurOffset[5] * ScreenParams.y)).r;

		if (value0 > 0.0f)
			color = value0;
		if (value1 > 0.0f)
			color = value1;
		if (value2 > 0.0f)
			color = value2;
		if (value3 > 0.0f)
			color = value3;
		if (value4 > 0.0f)
			color = value4;
		if (value5 > 0.0f)
			color = value5;
	    return 1 - color;
	}

    ENDCG

    SubShader
	{
		LOD 200

	    Pass
        {
			Name "OutputGrayTerrs0"
		   //Cull front
            ZWrite Off
			BlendOp Max
		    Blend SrcAlpha DstAlpha

            CGPROGRAM           
            #pragma vertex MainVS
            #pragma fragment  OutputGrayTerrPS
            #pragma target 2.0
			ENDCG
        }
		Pass
		{
			Name "OutputGrayTerrs1"
			//Cull front
			ZWrite Off
			BlendOp Min
			Blend SrcAlpha DstAlpha

			CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  OutputGrayTerrPS
            #pragma target 2.0
			ENDCG
		}
	    Pass
		{
			Name "OutputGrayTerrOnlyOne"

			ZWrite Off

			CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  OutputGrayTerrPS
            #pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "HorizontalDilation"

			ZWrite Off

			CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  HorizontalDilation7x7PS
            #pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "VerticalDilation"

		    ZWrite Off

			CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  VerticalDilation7x7PS
            #pragma target 2.0
			ENDCG
		}

		Pass
	    {
		    Name "OutputGrayTerrsOnlyOneWithAnimation"
		    ZWrite Off
		    BlendOp Min
		    Blend SrcAlpha DstAlpha
		   
		    CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  OutputGrayTerrWithAnimationPS
            #pragma target 2.0
		    ENDCG
	   }
   }
}
