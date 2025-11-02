Shader "YueChuan/Others/BackgroudScroll" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_ScrollSpeed("X:Horizontal Speed, Y:Vertical Speed", Vector) = (1,0,0,0)
	}
    SubShader 
    {
	    Tags
        {
            "Queue"="Background"
        }

        Fog
        {
            Mode Off
        }

        Pass 
        {
            Cull off
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            
            uniform half4 _MainTex_ST;
            uniform half4 _Color;
            uniform half4 _ScrollSpeed;
            
            struct VS_OUTPUT
            {
                float4 v4Position : SV_POSITION;
                half2 v2Texcoord : TEXCOORD0;
            };

            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.v4Position = mul (UNITY_MATRIX_MVP, input.vertex);
				output.v2Texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
               
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                float2 uv = input.v2Texcoord - fmod(_Time.x * _ScrollSpeed.xy, 1.0);
                fixed4 color = tex2D(_MainTex, uv) * _Color;
                return color;
            }

            ENDCG
        }
    }
}
