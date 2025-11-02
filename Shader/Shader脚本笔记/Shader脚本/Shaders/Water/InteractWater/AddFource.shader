//第一步
Shader "YueChuan/InteractWater/AddFource" 
{
    Properties 
	{
		_Force(" Force ", Float) = 1.0
		_WaterPlaneY(" Water PlaneY ", Float) = 0.0
	}
    SubShader 
    {
		Tags { "RenderType"="Opaque" }
        Pass 
        {
			Lighting Off
			ZWrite Off
			AlphaTest Off
			cull off
			Blend One One
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"

            uniform half _WaterPlaneY;
            uniform half _Force;
        
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
                float4 v4WolrdPos : TEXCOORD0;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v4WolrdPos = mul(_Object2World, input.vertex);
                return output;
            }
            
            //把高度分解成(RGBA)4个数值
            fixed4 EncodeHeightmap(float fHeight)
            {
	            half h = fHeight;
	            half positive = fHeight > 0 ? fHeight : 0;
	            half negative = fHeight < 0 ? -fHeight : 0;

	            fixed4 color = 0;

	            color.r = positive;
	            color.g = negative;
	
		        //把小数点中比较低的位数放在(b,a)中
		        color.ba = frac(color.rg*256);
		        // (r,g) 存储的是位数比较高的部分
		        color.rg -= color.ba/256.0f;
	            return color;
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {   
                if ((_WaterPlaneY - input.v4WolrdPos.y) < 0.0)
                   return 0;
	            fixed4 color = EncodeHeightmap(_Force);
	            return color;
            }
            ENDCG
        }
    }
}
