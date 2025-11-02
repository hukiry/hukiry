Shader "YueChuan/Simple/ProjectGridWater" 
{
	CGINCLUDE

    #include "UnityCG.cginc"

	uniform sampler2D _ReflectTex;
	uniform sampler2D _WaterBump;
	uniform sampler2D _TerrainMap;
	uniform sampler2D _FoamMap;
	uniform sampler2D _FresnelMap;

	uniform float4x4 _MatrixVPInverse;
	uniform half _WaterRendererHeight;
	uniform half _ReflectDistort;

	uniform half3 _TerrainMapPatch;
	uniform half2 _TerrainMapControl;
	uniform half2 _Patch;
	uniform half2 _LongWave0Speed;
	uniform half2 _LongWave1Speed;
	uniform half2 _ShortWave0Speed;
	uniform half2 _ShortWave1Speed;

	uniform half4 _SunDir;
	uniform fixed4 _WaterbodyColor;
	uniform fixed4 _SunColor;

	struct VS_OUTPUT
	{
		float4 Position : SV_POSITION;
		half2 v2Texcoord : TEXCOORD0;
		float4 v4Proj : TEXCOORD1;
		float3 v3ViewDir : TEXCOORD2;
		half2  v2Wave0 : TEXCOORD3;
		half2  v2Wave1 : TEXCOORD4;
		half2  v2Wave2 : TEXCOORD5;
		half2  v2Wave3 : TEXCOORD6;

	};

	float3 Insect(float3 start, float3 end, float fplaneHeight)
	{
		float3 k = end - start;
		float3 result = 0;
		if (abs(k.y - 0.0000001f) > 0)
		{
			float t = (fplaneHeight - start.y) / k.y;
			result.xz = start.xz + k.xz * t;
			result.y = fplaneHeight;
		}
		return result;
	}

	VS_OUTPUT MainVS(appdata_base input)
	{
		VS_OUTPUT output = (VS_OUTPUT)0;

		float4 startInProjSpace = float4(input.vertex.xz, 0, 1);
		float4 endInProjSpace = float4(input.vertex.xz, 1, 1);
		float4 startInWolrdSpace = mul(_MatrixVPInverse, startInProjSpace);
		float4 endInWolrdSpace = mul(_MatrixVPInverse, endInProjSpace);
		startInWolrdSpace /= startInWolrdSpace.w;
		endInWolrdSpace /= endInWolrdSpace.w;

		float3 newPos = Insect(startInWolrdSpace.xyz, endInWolrdSpace.xyz, _WaterRendererHeight);
		output.Position = mul(UNITY_MATRIX_VP, float4(newPos.xyz, 1));

		output.v2Texcoord = newPos.xz;
		output.v3ViewDir = normalize(_WorldSpaceCameraPos.xyz - newPos.xyz);
		output.v4Proj = ComputeScreenPos(output.Position);

		half2 v2Wave01UV = newPos.xz * _Patch.x;
		half2 v2Wave23UV = newPos.xz * _Patch.y;
		output.v2Wave0 = v2Wave01UV + fmod(_Time.y * _LongWave0Speed, 1);
		output.v2Wave1 = v2Wave01UV * 2 + fmod(_Time.y * _LongWave1Speed, 1);
		output.v2Wave2 = v2Wave23UV + fmod(_Time.y * _ShortWave0Speed, 1);
		output.v2Wave3 = v2Wave23UV * 2 + fmod(_Time.y * _ShortWave1Speed, 1);

		return output;
	}

	fixed4 MainPS(VS_OUTPUT input) : COLOR
	{
		half2 terrainUV = input.v2Texcoord *_TerrainMapPatch.x + _TerrainMapPatch.yz;
		fixed terrainOutLine = tex2D(_TerrainMap, terrainUV) * _TerrainMapControl.x + _TerrainMapControl.y;

		fixed4 bumpNormal0 = tex2D(_WaterBump, input.v2Wave0);
		fixed4 bumpNormal1 = tex2D(_WaterBump, input.v2Wave1);
		fixed4 bumpNormal2 = tex2D(_WaterBump, input.v2Wave2);
		fixed4 bumpNormal3 = tex2D(_WaterBump, input.v2Wave3);

		fixed3 longwave = (UnpackNormal(bumpNormal0) + UnpackNormal(bumpNormal1))* 0.5;
		fixed3 shortwave = (UnpackNormal(bumpNormal2) + UnpackNormal(bumpNormal3))* 0.5;
		fixed3 bumpNormal = longwave * 0.5 + shortwave * 0.5;

		half3 vReflectBump = longwave *_ReflectDistort;
		half4 v4ReflectUV = UNITY_PROJ_COORD(input.v4Proj + half4(vReflectBump.xy, 0, 0));
		fixed3 v3ReflectColor = tex2Dproj(_ReflectTex, v4ReflectUV).xyz;
		v3ReflectColor *= v3ReflectColor;

		half NdotL = max(dot(input.v3ViewDir.xzy, bumpNormal), 0);
		half fresnel = tex2D(_FresnelMap, float2(NdotL, 0)).r;

		half3 reflectDir = normalize(reflect(-input.v3ViewDir.xzy, bumpNormal));
		half specularfactor = pow(max(0, dot(_SunDir.xyz, reflectDir)), _SunDir.w);

		fixed3 waterColor = 0;
		waterColor = lerp(_WaterbodyColor,v3ReflectColor, fresnel);
		waterColor += specularfactor * _SunColor.rgb;
		return fixed4(waterColor, 1 - terrainOutLine);
	}
	ENDCG
	SubShader
	{
		Tags
	    {
		     "Queue" = "Transparent"
		     "IgnoreProjector" = "True"
		     "RenderType" = "Transparent"
    	}
		LOD 200
		pass
	    {
		    Name "ProjectGridWater"
			Lighting Off
			AlphaTest Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

           #pragma vertex MainVS
           #pragma fragment MainPS
           #pragma target 2.0

			ENDCG
	    }
	}
}
