Shader "YueChuan/InteractWater/RenderWaterLow" 
{
    Properties 
	{
	    _ReflectTex ("_Reflect Texture (RGB)", Cube) = "" { TexGen CubeReflect }
		_WaterShapeTex ("Water Shape Tex", 2D) = "white" {}
		_WaterColor ("Water Color", Color) = (1.0,1.0,1.0,1.0)
	}
    SubShader 
    {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent-1"}
        //Fog { Mode off }
		Lighting Off

        // Render the object with the texture generated above, and invert it's colors
        Pass 
        {
		    Blend SrcAlpha OneMinusSrcAlpha
        
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform samplerCUBE _ReflectTex : register(s0);
            uniform sampler2D _WaterShapeTex : register(s1);
        
            uniform fixed4 _WaterColor;
        
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
				half3  v3ViewDir : TEXCOORD0;
				half2  v2Texcoord : TEXCOORD1;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                
                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v3ViewDir.xzy = normalize(WorldSpaceViewDir(input.vertex).xyz);
                output.v2Texcoord = input.texcoord;
                
                return output;
            }

            fixed4 MainPS(VS_OUTPUT input) : COLOR 
            {   
	            half waterShape = tex2D(_WaterShapeTex, input.v2Texcoord).r;
                fixed3 v3ReflectColor = texCUBE(_ReflectTex,input.v3ViewDir.xyz).rgb;
				return fixed4(v3ReflectColor * _WaterColor.rgb,waterShape * _WaterColor.a);
            }
            ENDCG
        }
    }
}
