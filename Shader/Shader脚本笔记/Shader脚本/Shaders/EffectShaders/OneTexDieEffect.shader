Shader "Custom/OneTexDieEffect"
{
	Properties
	{
		_tex1 ("Base (RGB)", 2D) = "white" {}
		_MainLight("MainLight",float)=1.2
		_MainAlpha("MainAlpha",Range (0,0.9))=0
		_Color ("Main Color", Color) = (1,1,0,1)
		_MaskMap ("MaskMap", 2D) = "white" {}
		_MaskRp("MaskRp",float)=1
		_Amount ("Amount", Range (0, 2)) = 0
	}

	SubShader
	{
		LOD 200
		Tags
		{
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
		}

		Pass
			{
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

				sampler2D _tex1;

				half _MainLight;
				sampler2D _MaskMap;
				half _MainAlpha;
				half3 _Color;
				half _Amount;
				half _MaskRp;

				struct appdata
				{
					fixed4 color : COLOR;
					fixed4 vertex : POSITION;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					fixed4 pos : POSITION;
					fixed2 uv : TEXCOORD0;
					fixed4 color : COLOR0;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.uv = v.texcoord;
					o.color = v.color;
					return o;
				}

				fixed4 frag(v2f IN) : COLOR
				{
					half4 h = tex2D(_MaskMap, IN.uv*_MaskRp);
					float ClipAmount = 1 + h.x - _Amount;
					if (ClipAmount <= 0)
					{
						discard;
					}

					fixed4 c = tex2D(_tex1, IN.uv);
					c.rgb = c.rgb * _MainLight + _Color.rgb*_MainAlpha;
					return c;
				}
				ENDCG
			}
	} 
	FallBack "Diffuse"
}