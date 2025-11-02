//镂空，AlphaTest,纹理旋转，漫反射，高光
Shader "deffuse_AlphaTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Specular ("_Specular", COLOR) = (1,1,1,1)//高光纹理
		_goss("_goss",float)=20
		_cout("_cout",Range(0,1))=0.5
		_RotateSpeed("_RotateSpeed",Range(0,180))=1
	}
	SubShader
	{
		//Cull Off ZWrite Off ZTest Always
		Tags{"Queue"="AlphaTest" "RenderType" = "Transparent" "IgnoreProjector" = "True"}//队列渲染，透明着色器，忽略阴影接受
		Pass
		{
			Tags{"LightMode"="ForwardBase"}//向前灯光模式
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma fragmentoption ARB_precision_hint_fastest  
            #pragma multi_compile_fwdbase  
			#pragma multi_compile_fwdadd
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata//shader 加载时从Unity Meshrenderer组件中获取：顶点位置，法线，切线，顶点颜色，切线，纹理坐标
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 uv : TEXCOORD0;
				float3 tangment:TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 norDir:NORMAL;
				float3 lightDir:TEXCOORD1;
				float4 worldPos:TEXCOORD2;
				float3 tangment:TANGENT;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Specular;
			float _goss;
			float _cout;
			float _RotateSpeed;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);//输出模型顶点到屏幕
	
				o.worldPos=mul(_Object2World,v.vertex);//世界顶点位置

				o.lightDir=normalize(_WorldSpaceLightPos0-o.worldPos);//WorldSpaceLightDir(v.vertex) 灯光方向的计算

				o.norDir=mul(v.normal,(float3x3)_World2Object);//世界法线

				o.tangment=mul(_Object2World,v.tangment);//世界切线

				o.uv=v.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;//等价于TRANSFORM_TEX(uv,tex) 纹理变换，xy缩放,zw偏移
//-------------------------start 纹理旋转-----------------------------------------------------
				float2 uv=o.uv.xy -float2(0.5,0.5); 
				// _Time   是一个内置的float4时间，X是1/20，Y是1倍，Z是2倍，W是3倍           
				// 旋转矩阵的公式是： COS() -  sin() , sin() + cos()     顺时针
				//                    COS() +  sin() , sin() - cos()     逆时针     
				float x=uv.x*cos(_RotateSpeed * _Time.y) - uv.y*sin(_RotateSpeed*_Time.y);

				float y=uv.x*sin(_RotateSpeed * _Time.y) + uv.y*cos(_RotateSpeed*_Time.y);

				uv = float2(x,y);

				uv += float2(0.5,0.5);

				o.uv=uv;
//-------------------------end 纹理旋转-----------------------------------------------------
//TRANSFER_SHADOW(v);

				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);//主纹理颜色

				clip(col.a-_cout);//镂空alpha计算 

				fixed d=dot(i.norDir,i.lightDir)*0.5+0.5;//比较亮

				fixed4 diff=_LightColor0*col*d;//漫反射光	 diff=L*color*dot(n,l);

				fixed4 ambient=UNITY_LIGHTMODEL_AMBIENT*col;//环境光,	不乘以纹理颜色会白一点

				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos-i.worldPos);  //WorldSpaceViewDir(v.vertex)视角方向
                fixed h = normalize(viewDir + i.lightDir);  //半兰伯特计算
                fixed4 spec= _LightColor0*col * pow(dot(i.norDir, h)*0.5+0.5, _goss) ;  //高光=灯光颜色*纹理颜色*（dot(n,h)的次方）

				return diff+ambient+spec;//漫反射+环境光+高光
			}
			ENDCG
		}
	}
}
