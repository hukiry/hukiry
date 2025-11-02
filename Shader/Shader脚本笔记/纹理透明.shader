//高光+纹理透明
Shader "Transparent"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}//主纹理
		_Specular ("_Specular", COLOR) = (1,1,1,1)//高光纹理或颜色
		_goss("_goss",float)=20//高光强度
	}
	SubShader
	{
		Tags{"Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True"}
		Blend SrcAlpha OneMinusSrcAlpha//开启透明混合
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 norDir:NORMAL;
				float3 lightDir:TEXCOORD1;
				float4 worldPos:TEXCOORD2;

			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Specular;
			float _goss;
			float _cout;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	
				o.worldPos=mul(_Object2World,v.vertex);

				o.lightDir=normalize(_WorldSpaceLightPos0-o.worldPos);//WorldSpaceLightDir(v.vertex)

				o.norDir=mul(v.normal,(float3x3)_World2Object);

				o.uv=v.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;//等价于TRANSFORM_TEX(uv,tex)

				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed d=dot(i.norDir,i.lightDir)*0.5+0.5;//比较亮

				fixed4 diff=_LightColor0*col*d;//漫反射光

				fixed4 ambient=UNITY_LIGHTMODEL_AMBIENT*col;//环境光,不乘以纹理颜色会白一点

				fixed3 viewDir = normalize(_WorldSpaceCameraPos-i.worldPos);  //WorldSpaceViewDir(v.vertex)

                fixed h = normalize(viewDir + i.lightDir);  

                fixed4 spec= _LightColor0*col * pow(dot(i.norDir, h)*0.5+0.5, _goss) ;  

				return diff+ambient+spec;//不加环境光，半边暗
			}
			ENDCG
		}

	}
}
