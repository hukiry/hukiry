Shader "Billy/RainGlass_OP"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size("Size",Float)= 1
		_Distortion("Distortion",range(0,1))=1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;
            float _Distortion;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			

			float N21(float2 p){
				p = frac(p*float2(123.34,345.45));
				p +=dot( p,p+34.345 ) ;
				return frac(p.x*p.y);
}

			fixed4 frag (v2f i) : SV_Target
			{	
				float t = fmod(_Time.y,7200);
				float4 col =0;
				float2 aspect = float2(2, 1);
				float2 uv = i.uv*_Size*aspect;

				uv.y += t * 0.25;
				float2 gv = frac(uv)-0.5;
				float2 id = floor(uv); 
			

				float n =N21(id);

				t+= n*6.28631;


				float w = i.uv.y *10;

				float x = (n-0.5)*0.8;

				x += (0.4-abs(x))*sin(3*w)*pow(sin(w),6)*0.45;
				float y =-sin(t+sin(t+sin(t)*0.5))*0.45;

				y -= (gv.x-x)*(gv.x-x);
			

				float2 dropPos =(gv - float2(x, y))/aspect;
				float drop = smoothstep(0.05,0.03,length(dropPos));

		
				float2 dropTrailPos = (gv - float2(x, t*0.25)) / aspect;
				dropTrailPos.y = (frac(dropTrailPos.y* 8)/8)-0.03;
				float dropTrail = smoothstep(0.03, 0.02, length(dropTrailPos));
				float fogTrail = smoothstep(-0.05, 0.05, dropPos.y);
				fogTrail *= smoothstep(0.5, y, gv.y);
				dropTrail *= fogTrail;

				fogTrail *= smoothstep(0.05,0.04,abs(dropPos.x));

				col += fogTrail*0.5;
				col += dropTrail;
				col += drop;

				
				float2 offs = drop*dropPos+dropTrail*dropTrailPos;
				col = tex2D(_MainTex,i.uv+offs*_Distortion);
				return col;
			}
			ENDCG
		}
	}
}