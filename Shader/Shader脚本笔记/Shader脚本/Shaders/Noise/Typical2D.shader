Shader "YueChuan/PerlinNoise/Typical2D" 
{

	 CGINCLUDE
	 #include "UnityCG.cginc"

	 uniform float _Octaves;
	 uniform float _Persistence;
	 uniform float _Lacunarity;
	 uniform float _Frequency;
	 uniform float _Amplitude;
     uniform float2 _Seed;
        
     struct VS_OUTPUT
     {
            float4 Position : SV_POSITION;
		    half2 v2Texcoord : TEXCOORD0;
     };
            
     VS_OUTPUT MainVS(appdata_base input)
     {
           VS_OUTPUT output = (VS_OUTPUT)0;
                
           output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
           output.v2Texcoord = input.texcoord.xy;

           return output;
      }

	   // 伪随机数[-1,1]
	   float noise(float2 pos)
	   {
		    pos += (int2)_Seed;
		    return 2.0 * frac(sin(dot(pos*0.001, float2(24.12357, 36.789))) * 12345.123) - 1.0;
	   }

	    //五次样条线插值
		float fifthSplineInterpolate(float a, float b, float t)
		{
			float f = t * t * t * (t * (t * 6.0f - 15.0f) + 10.0f);
			return lerp(a,b,f);
		}

		// 网格点的噪音进行3x3 box平滑
		float smoothNoise(float2 pos)
		{
			float corners = (noise(pos + float2(1, 1)) + noise(pos + float2(-1, 1)) + noise(pos + float2(1, -1)) + noise(pos + float2(-1, -1))) / 16.0;
			float slides = (noise(pos + float2(1, 0)) + noise(pos + float2(-1, 0)) + noise(pos + float2(0, 1)) + noise(pos + float2(0, -1))) / 8.0;
			float center = noise(pos) / 4.0;
			return corners + slides + center;
		}

		// 网格内点的噪音通过两次样条线插值得到
		float interpolateNoise(float2 pos,float frequency)
		{
			pos *= frequency;
			float2 integerXY = floor(pos);
			float2 fracXY = frac(pos);

			float v1 = smoothNoise(fmod(integerXY, frequency));
			float v2 = smoothNoise(float2(fmod(integerXY.x + 1.0, frequency), integerXY.y));
			float v3 = smoothNoise(float2(integerXY.x, fmod(integerXY.y + 1.0, frequency)));
			float v4 = smoothNoise(float2(fmod(integerXY.x + 1.0, frequency), fmod(integerXY.y + 1.0, frequency)));

			float i1 = fifthSplineInterpolate(v1, v2, fracXY.x);
			float i2 = fifthSplineInterpolate(v3, v4, fracXY.x);

			return fifthSplineInterpolate(i1, i2, fracXY.y);
		}

		//分型叠加
		float fractalAdditive(float2 pos)
		{
			float sum = 0.0f;
			for (int i = 0; i < _Octaves; i++)
			{
				float amplitude = _Amplitude;
				float frequency = _Frequency;
				float perlinNoise = interpolateNoise(pos,frequency) * amplitude;
				sum += perlinNoise;
				frequency *= _Lacunarity;
				amplitude *= _Persistence;
			}
			return sum;
		}

        float4 TypicalPS(VS_OUTPUT input) : COLOR 
        {   
		    float noise = fractalAdditive(input.v2Texcoord);
			noise = 0.5 + noise * 0.5;
		    return float4(noise, noise, noise, noise);
         }
		
		uniform float _CloudShapness;
	    //云纹理
		float4 CloudPS(VS_OUTPUT input) : COLOR
		{
			float noise = interpolateNoise(input.v2Texcoord,_Frequency) * _Amplitude;
		    noise += interpolateNoise(input.v2Texcoord, _Frequency * 2) * _Amplitude * 0.5;
		    noise += interpolateNoise(input.v2Texcoord, _Frequency * 4) * _Amplitude * 0.25;
		    noise += interpolateNoise(input.v2Texcoord, _Frequency * 8) * _Amplitude * 0.125;
		
		     noise = 0.5 + noise * 0.5;
			 noise *= noise;
		     float density = pow(noise,_CloudShapness);
		     return density;
		 }

         ENDCG
	     SubShader 
	     {
		       Tags { "RenderType"="Opaque" }
		        LOD 200
		        Pass
		        {
					  Lighting Off
					  ZWrite Off
				      AlphaTest Off
			          Name "Typical"
			          CGPROGRAM

                      #pragma vertex MainVS
                      #pragma fragment TypicalPS
                      #pragma target 3.0
           
                      ENDCG
		        }
			    Pass
			    {
					  Lighting Off
					  ZWrite Off
				      AlphaTest Off
				       Name "Cloud"
				       CGPROGRAM

                       #pragma vertex MainVS
                       #pragma fragment CloudPS
                       #pragma target 3.0

				       ENDCG
			    }
	    }
}
