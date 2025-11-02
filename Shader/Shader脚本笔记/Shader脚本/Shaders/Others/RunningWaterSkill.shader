Shader "YueChuan/Others/RunningWaterSkill"
{
	Properties
	{
		_TintColor("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex("Particle Texture", 2D) = "white" {}
	    _ScrollSpeed("X:Horizontal Speed, Y:Vertical Speed,Z: Fade Speed", Vector) = (1,0,1,0)

	}
		SubShader
	    {
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		    Pass
	        {
	        	Blend One OneMinusSrcColor
	         	//Blend SrcAlpha OneMinusSrcAlpha

		        ColorMask RGB
		        Cull Off Lighting Off ZWrite Off Fog{ Color(0,0,0,0) }
		        CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0

                #include "UnityCG.cginc"

		        uniform sampler2D _MainTex;
	            uniform fixed4 _TintColor;
	            uniform half4 _ScrollSpeed;

	            struct appdata_t
	            {
		              float4 vertex : POSITION;
		              fixed4 color : COLOR;
		              float2 texcoord : TEXCOORD0;
	            };

              	struct v2f
	            {
		              float4 vertex : SV_POSITION;
		              fixed4 color : COLOR;
		              float2 texcoord : TEXCOORD0;
	            };

	            float4 _MainTex_ST;

	            v2f vert(appdata_t v)
	            {
		             v2f o;
		             o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		             o.color = v.color;
		             o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
		             return o;
	             }

                float ThirdSplineInterpolate(float a, float b, float t)
	            {
		             float f = t * t * (-2 * t + 3);
		             return a * (1 - f) + b * f;
	            }

	            fixed4 frag(v2f i) : SV_Target
	            {
		             float2 uv = i.texcoord - fmod(_Time.x * _ScrollSpeed.xy, 1.0);

		             half4 prev = i.color * tex2D(_MainTex, uv);
		             prev.rgb *= prev.a;
		             return prev * _TintColor *  ThirdSplineInterpolate(1,0,saturate(_Time.x * _ScrollSpeed.z));
	            }
		         ENDCG
	       }
	 }
}
