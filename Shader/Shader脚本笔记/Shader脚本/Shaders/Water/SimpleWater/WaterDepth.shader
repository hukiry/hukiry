Shader "YueChuan/SimpleWater/WaterDepth" 
{
	Properties 
	{
		[HideInInspector]_WaterPlane("Water Plane",Float) = 0.0
		[HideInInspector]_LightCanReachDepth("Light Can Reach Depth",Float) = 2.0
	}
	SubShader
	{
        Tags { "Queue" = "Transparent-1"}
		LOD 200
		Fog { Mode off }
		Lighting Off
	    Pass 
        {
            CGPROGRAM
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform half _WaterPlane;
            uniform half _LightCanReachDepth;
           
             struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
                half  DistToWaterPlane : TEXCOORD0;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
               VS_OUTPUT output = (VS_OUTPUT)0;
               output.Position = mul(UNITY_MATRIX_MVP,input.vertex);
               
               float4 WPos = mul(_Object2World,input.vertex);
               output.DistToWaterPlane = _WaterPlane - WPos.y;
               return output;
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {
                return EncodeFloatRGBA(clamp(0,0.9999,input.DistToWaterPlane/_LightCanReachDepth));
            }
            ENDCG
        }
   }
}
