//高光+前后剔除（可以看见背面）+纹理透明+镂空
Shader "TransparentCullOFF"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Specular ("_Specular", COLOR) = (1,1,1,1)//高光纹理
		_goss("_goss",float)=20
		_cout("_cout",Range(0,1))=0.5
	}
	SubShader
	{
		Tags{"Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True"}
		//Blend SrcAlpha OneMinusSrcAlpha  //开启透明混合
		Cull Off
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		 //#pragma fragmentoption ARB_precision_hint_fastest  
   //         #pragma multi_compile_fwdbase  
			
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

				//o.uv = TRANSFORM_TEX(v.uv,_MainTex);可以在监测面板中控制缩放和平移
				//	o.uv =v.uv;//这个不可以操作ST
				_MainTex_ST.z-=_Time.x;

				o.uv=v.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;//等价于TRANSFORM_TEX(uv,tex)

				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a-_cout);//开启镂空
				//fixed4 speculerColor=tex2D(_Specular,TRANSFORM_TEX(i.uv,_Specular));
				//fixed d=max(0,dot(i.norDir,i.lightDir));//暗一点儿
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
