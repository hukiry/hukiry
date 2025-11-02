Shader "YueChuan/PostEffect/ResidualImage"
 {
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Tex0 ("Tex0 (RGBA)", 2D) = "black" {}
		_Tex1 ("Tex1 (RGBA)", 2D) = "black" {}
		_Tex2 ("Tex2 (RGBA)", 2D) = "black" {}
		_FadeTime ("Fade Time", Float) = 0.0
		_StopFadeTime ("Stop Fade Time", Float) = 0.0
		_ResidualWeight("Residual Weight",Vector) = (0,0,0,0)
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass 
        {
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform sampler2D _Tex0;
            uniform sampler2D _Tex1;
            uniform sampler2D _Tex2;
            
            uniform float _FadeTime;
            uniform float4 _ResidualWeight;
            
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
                float2 v2Texcoord : Texcoord0;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;

                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v2Texcoord = input.texcoord;

                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                //float fFadeTime = min(0.1,_FadeTime);
                float fFadeTime = _FadeTime;
                float2 v2Texcoord = input.v2Texcoord;
                float4 RGBColor = tex2D(_MainTex,v2Texcoord) * (_ResidualWeight.x + 3 * fFadeTime);
                RGBColor += (tex2D(_Tex2,v2Texcoord)* (max(_ResidualWeight.y - fFadeTime,0)));
                RGBColor += (tex2D(_Tex1,v2Texcoord)* (max(_ResidualWeight.z - fFadeTime,0)));
                RGBColor += (tex2D(_Tex0,v2Texcoord)* (max(_ResidualWeight.w - fFadeTime,0)));
                return RGBColor;
            }
            ENDCG
        }
        Pass 
        {
            CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            uniform sampler2D _Tex0;
            uniform sampler2D _Tex1;
            uniform sampler2D _Tex2;
            
            uniform float _FadeTime;
            uniform float _StopFadeTime;
            uniform float4 _ResidualWeight;
            
            struct VS_OUTPUT
            {
                float4 Position : SV_POSITION;
                float2 v2Texcoord : Texcoord0;
            };
            
            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;

                output.Position = mul(UNITY_MATRIX_MVP, input.vertex);
                output.v2Texcoord = input.texcoord;

                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
                //float fFadeTime = min(0.1,_FadeTime);
                float fFadeTime = _FadeTime;
                float2 v2Texcoord = input.v2Texcoord;
                float4 RGBColor = tex2D(_MainTex,v2Texcoord) * (_ResidualWeight.x + _StopFadeTime);
                RGBColor += (tex2D(_Tex2,v2Texcoord)* (max(_ResidualWeight.y - fFadeTime,0)));
                RGBColor += (tex2D(_Tex1,v2Texcoord)* (max(_ResidualWeight.z - fFadeTime,0)));
                RGBColor += (tex2D(_Tex0,v2Texcoord)* (max(_ResidualWeight.w - fFadeTime,0)));
                return RGBColor;
            }
            ENDCG
        }
	} 
}
