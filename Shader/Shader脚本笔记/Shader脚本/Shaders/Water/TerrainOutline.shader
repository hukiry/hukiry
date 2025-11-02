//为水面效果生成地形轮廓
Shader "YueChuan/Others/TerrainOutline" 
{
    SubShader 
    {
		Fog { Mode off }
        Pass 
        {
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform half _WaterPlaneY;

            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                float3 v3NewPos = input.vertex.xyz + input.normal * 1;
                output.Position = mul(UNITY_MATRIX_MVP, float4(v3NewPos,1.0f));
                return output;
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {   
	            return 1;
            }
            ENDCG
        }
    }
}
