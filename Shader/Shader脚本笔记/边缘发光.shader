
//边缘发光，算法一致
Shader "Custom/OutLine1" 
{
    Properties
    {
        _MainTex("MainTex",2D) = "black"{}
		_BumpMap("BumpMap",2D) = "black"{}
		_MainColor("_MainColor",Color)=(1,1,1,1)
        _EdgeColor("EdgeColorr",Color) = (1,1,1,1)//边缘颜色
        _RimPower ("rim power",range(1,10)) = 2//边缘强度
		_RimIntensity("【边缘发光强度系数】Rim Intensity", Range(0.0, 100)) = 3  
    }
 //边缘发光顶点片元着色器，较亮
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include"UnityCG.cginc"
 
            struct v2f
            {
                float4 vertex:POSITION;
                float4 uv:TEXCOORD0;
                float4 NdotV:COLOR;
            };
 
            sampler2D _MainTex;
            float4 _RimColor;
            float _RimPower;
 
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
                o.uv = v.texcoord;
                float3 V = mul(_World2Object,WorldSpaceViewDir(v.vertex));//视方向从世界到模型坐标系的转换
                o.NdotV.x = saturate(dot(v.normal,normalize(V)));//法线和视角的点乘，用视方向和法线方向做点乘，越边缘的地方，法线和视方向越接近90度，点乘越接近0.
                return o;
            }
 
            half4 frag(v2f IN):COLOR
            {
                half4 c = tex2D(_MainTex,IN.uv); 
            
                c.rgb += pow((1-IN.NdotV.x) ,_RimPower)* _RimColor.rgb;    //用（1- 上面点乘的结果）*颜色，来反映边缘颜色情况
                return c;
            }
            ENDCG
        }
    }

	////表面着色的边缘发光 ，有点暗
	SubShader {  
        Tags{ "RenderType" = "Opaque"}  
        LOD 150  
  
        CGPROGRAM  
   
        #pragma surface surf Lambert  
               
        struct Input {  
                float2 uv_MainTex;  
                float3 viewDir;  
        };  
   
        sampler2D _MainTex;  
        fixed4 _RimColor;  
        fixed _RimPower;  
   
        void surf (Input IN, inout SurfaceOutput o) {  
                fixed4 t = tex2D (_MainTex, IN.uv_MainTex);  
                o.Albedo = t.rgb;  
                o.Alpha = t.a;  
                half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));  
                o.Emission= _RimColor.rgb * pow (rim, _RimPower);  
        }  
  
        ENDCG  
	}  

	//表面着色的边缘发光 ，加入法线纹理
	SubShader
    {
        //RenderType渲染类型为Opaque，不透明
        Tags { "RenderType" = "Opaque" }
		CGPROGRAM

		//指令，表面着色器，名称，使用兰伯特光照模式
		#pragma surface surf Lambert

		//输入结构体
		struct Input
		{
			float2 uv_MainTex;         //纹理贴图
			float2 uv_BumpMap;      //法线贴图
			float3 viewDir;              //观察方向
		};

		//变量声明
		sampler2D _MainTex;         //主纹理
		sampler2D _BumpMap;      //凹凸纹理
		float4 _RimColor;              //边缘颜色
		float _RimPower;              //边缘颜色强度

		//表面着色函数的编写
		void surf (Input IN, inout SurfaceOutput o)
		{
			//表面反射颜色为纹理颜色
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
			//表面法线为凹凸纹理的颜色
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			//边缘颜色
			half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			//边缘颜色强度
			o.Emission = _RimColor.rgb * pow (rim, _RimPower);
		}

		//-------------------结束CG着色器编程语言段------------------
		ENDCG
    }

	SubShader  //缘发光，比较暗
    {  
        //渲染类型为Opaque，不透明 || RenderType Opaque  
        Tags  
        {  
            "RenderType" = "Opaque"  
        }  
  
        //---------------------------------------【唯一的通道 || Pass】------------------------------------  
        Pass  
        {  
            //设定通道名称 || Set Pass Name  
            Name "ForwardBase"  
  
            //设置光照模式 || LightMode ForwardBase  
            Tags  
            {  
                "LightMode" = "ForwardBase"  
            }  
  
            //-------------------------开启CG着色器编程语言段 || Begin CG Programming Part----------------------    
            CGPROGRAM  
  
                //【1】指定顶点和片段着色函数名称 || Set the name of vertex and fragment shader function  
                #pragma vertex vert  
                #pragma fragment frag  
  

                #include "UnityCG.cginc"  
                #include "AutoLight.cginc"  
                #pragma target 3.0  
  
                //系统光照颜色  
                uniform float4 _LightColor0;  
                //主颜色  
                uniform float4 _MainColor;  
                //漫反射纹理  
                uniform sampler2D _BumpMap;   
                //漫反射纹理_ST后缀版  
                uniform float4 _BumpMap_ST;  
                //边缘光颜色  
                uniform float4 _RimColor;  
                //边缘光强度  
                uniform float _RimPower;  
                //边缘光强度系数  
                uniform float _RimIntensity;  
  
                struct VertexInput   
                {  
                    //顶点位置 || Vertex position  
                    float4 vertex : POSITION;  
                    //法线向量坐标 || Normal vector coordinates  
                    float3 normal : NORMAL;  
                    //一级纹理坐标 || Primary texture coordinates  
                    float4 texcoord : TEXCOORD0;  
                };  
  
                struct VertexOutput   
                {  
                    //像素位置 || Pixel position  
                    float4 pos : SV_POSITION;  
                    //一级纹理坐标 || Primary texture coordinates  
                    float4 texcoord : TEXCOORD0;  
                    //法线向量坐标 || Normal vector coordinates  
                    float3 normal : NORMAL;  
                    //世界空间中的坐标位置 || Coordinate position in world space  
                    float4 posWorld : TEXCOORD1;  
                    //创建光源坐标,用于内置的光照 || Function in AutoLight.cginc to create light coordinates  
                    LIGHTING_COORDS(3,4)  
                };  
  
                VertexOutput vert(VertexInput v)   
                {  
                    VertexOutput o;  
                    //将输入纹理坐标赋值给输出纹理坐标  
                    o.texcoord = v.texcoord;  
                    //获取顶点在世界空间中的法线向量坐标    
                    o.normal = mul(float4(v.normal,0), _World2Object).xyz;  
                    //获得顶点在世界空间中的位置坐标    
                    o.posWorld = mul(_Object2World, v.vertex);  
                    //获取像素位置  
                    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);  
  
                    return o;  
                }  

                fixed4 frag(VertexOutput i) : COLOR  
                {  
                    //视角方向  
                    float3 ViewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);  
                    //法线方向  
                    float3 Normalection = normalize(i.normal);  
                    //光照方向  
                    float3 LightDirection = normalize(_WorldSpaceLightPos0.xyz);  

                    float Attenuation = LIGHT_ATTENUATION(i);  //灯光衰减强度

                    float3 AttenColor = Attenuation * _LightColor0.xyz;  

                    float3 Diffuse = max(0.0, dot(Normalection, LightDirection)) * AttenColor + UNITY_LIGHTMODEL_AMBIENT.xyz;  //漫反射计算
  

                    half Rim = 1.0 - max(0, dot(i.normal, ViewDirection));  //边缘发光计算
                    float3 Emissive = _RimColor.rgb * pow(Rim,_RimPower) *_RimIntensity;  //自发光计算
                    float3 finalColor = Diffuse * (tex2D(_BumpMap,TRANSFORM_TEX(i.texcoord.rg, _BumpMap)).rgb*_MainColor.rgb) + Emissive;  //所有纹理采样，加上自发光，纹理采样，漫反射
                  
                    return fixed4(finalColor,1);  
                }  
  
            //-------------------结束CG着色器编程语言段 || End CG Programming Part------------------    
            ENDCG  
        }  
    }  

	//上面的使用的是法线与视方向的点乘，取边缘值。本列属于经典边缘发光，使用sober的算法
	 SubShader
     {
         Pass
         {
             Cull Off
             ZWrite Off
             ZTest Always
 
             CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag
 
             sampler2D _MainTex;
             float4 _MainTex_TexelSize;
             uniform fixed4 _EdgeColor;
 
             struct appdata
             {
                 float4 vertex : POSITION;
                 float2 uv : TEXCOORD0;
             };
 
             struct v2f
             {
                 float4 pos : SV_POSITION;
                 half2 uv[9] : TEXCOORD0;
             };
 
             v2f vert(appdata v)
             {
                 v2f o;
                 o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				 //使用了sober的算法
                 o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1);
                 o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(0, 1);
                 o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(1, 1);
                 o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0);
                 o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, 0);
                 o.uv[5] = v.uv + _MainTex_TexelSize.xy * half2(1, 0);
                 o.uv[6] = v.uv + _MainTex_TexelSize.xy * half2(-1, -1);
                 o.uv[7] = v.uv + _MainTex_TexelSize.xy * half2(0, -1);
                 o.uv[8] = v.uv + _MainTex_TexelSize.xy * half2(1, -1);
                 return o;
             }
 
             float luminance(float3 color)
             {
                 return dot(fixed3(0.2125, 0.7154, 0.0721), color);
             }
 
             half sober(half2 uvs[9])
             {
				//见 shader 入门精要 高级篇边缘发光
                 half gx[9] = {    -1, 0, 1,
                                 -2, 0, 2,
                                 -1, 0, 1};
                 half gy[9] = {    -1, -2, -1,
                                 0, 0, 0,
                                 1, 2, 1};
 
                 float edgeX = 0;
                 float edgeY = 0;
 
                 for(int i = 0; i < 9; i++)
                 {
                     fixed3 c = tex2D(_MainTex, uvs[i]).rgb;
                     float l = luminance(c);
                     edgeX += l * gx[i];
                     edgeY += l * gy[i];
                 }
 
                 return abs(edgeX) + abs(edgeY);
             }
 
             fixed4 frag(v2f i) : SV_TARGET
             {
                 half edge = sober(i.uv);
                 fixed4 tex = tex2D(_MainTex, i.uv[4]);
                 return lerp(tex, _EdgeColor, edge);
             }
             
             ENDCG
         }
     }
    FallBack "Diffuse"
}