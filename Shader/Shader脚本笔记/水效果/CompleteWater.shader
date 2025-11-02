Shader "MyWater/CompleteWater"
{
    Properties
    {
        [NoScaleOffset]_ReflectionTexture("反射贴图(From ToolForWater)",2D)="white"{}
        _Gloss("Gloss",Range(8,256))=20 
        
        [Header(Water Properties)]
        _WaterColor("水体颜色",Color)=(1,1,1,1)
        _WaterDensity("水体密度",Range(0,2))=0.5
        _Fresnel("菲涅尔",Range(0,1))=2
        [Header(Water Flow)]
        [Toggle(_DUAL_GRID)] _DualGrid ("双重混合", Int) = 0//用toggle特性 名字会变成一个关键字
        _DerivHeightMap ("导数 (AG) 高度 (B)", 2D) = "white" {}
        [NoScaleOffset]_FlowMap ("水体流向(RG),流速(B),噪声(A)", 2D) = "white" {}
        _GridResolution("流向分辨率",Float)=10
        _FlowSpeed("流速",Range(0,0.5))=1
        _FlowStrength("流动强度",Float)=1
        _Tile("Tile",Float)=1//波纹图案大小
        _TilingModulated ("Tiling, Modulated", Float) = 1//流速对默认大小的影响程度，一般来说流速越快波纹越细密
        _HeightScale ("Height Scale", Float) = 0.25//浪高缩放值
        _HeightScaleModulated ("Height Scale, Modulated", Float) = 0.75//随速度递增的高度缩放值
        
        [Header(Water Wave)]
        _TessellationEdgeLength("细分边长（值越高精度越低）",Range(5,100))=50//细分段的长度
        [Toggle(_WAVE_A_OPEN)]_enableA("开启波A",Int)=0
        _WaveA("Wave A:dir,steepness,wavelength",Vector)=(1,0,0.5,10)
        _WaveASpeed("speed",Float)=1
        [Toggle(_WAVE_B_OPEN)]_enableB("开启波B",Int)=0
        _WaveB("Wave B", Vector) = (0,1,0.25,20)
        _WaveBSpeed("speed",Float)=1
        [Toggle(_WAVE_C_OPEN)]_enableC("开启波C",Int)=0
        _WaveC ("Wave C", Vector) = (1,1,0.15,10)
        _WaveCSpeed("speed",Float)=1
        
        [Header(Water Foam)]
        _FoamTexture("泡沫贴图",2D)="white"{}
        _Foam1Range("外围泡沫范围",Range(0,1))=0.5
        _Foam2Range("内围泡沫移动范围",Range(0,1))=0.2
        _Foam2Speed("内围泡沫移动速度",Float)=1
        
        
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue"="Transparent"}
        GrabPass{"_RefractionTexture"}

        Pass{
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma target 4.0  

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma shader_feature _DUAL_GRID
            #pragma shader_feature _WAVE_A_OPEN
            #pragma shader_feature _WAVE_B_OPEN
            #pragma shader_feature _WAVE_C_OPEN
            
            sampler2D _NormalMap,_FoamTexture;
            float4 _MainTex_ST,_FoamTexture_ST;
            
            sampler2D _CameraDepthTexture,_RefractionTexture;
            sampler2D _ReflectionTexture;
            float4 _CameraDepthTexture_TexelSize;
            
            float _Gloss,_WaterDensity,_Fresnel;
            float3 _WaterColor;
            
            sampler2D _DerivHeightMap,_FlowMap;
            float4 _DerivHeightMap_ST;
            float _FlowSpeed,_FlowStrength,_Tile,_TilingModulated,_HeightScale,_HeightScaleModulated,_GridResolution;
            
            float _TessellationEdgeLength;
            float4 _WaveA,_WaveB,_WaveC;
            float _WaveASpeed,_WaveBSpeed,_WaveCSpeed;
            
            float _Foam1Range,_Foam2Range,_Foam2Speed;

            //开启曲面细分使用的顶点函数，只单纯的传递数据，真正对顶点的修改放到Domain中
    
            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 texcoord:TEXCOORD0;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float4 ScreenPos:TEXCOORD1;
                float4 uvNF:TEXCOORD3;
                //切线到世界矩阵 第四分量存储世界位置
                float4 TtoW0 : TEXCOORD4;
                float4 TtoW1 : TEXCOORD5;
                float4 TtoW2 : TEXCOORD6;
                //float3 TangentLightDir:TEXCOORD4;
                //float3 TangentViewDir:TEXCOORD5;
            };

			//-----------------折射和反射------------------------------
			//计算折射颜色 默认贴图名为_RefractionTexture
			float3 RefractionColor(float4 screenPos,float3 worldNormal)
			{
				//法线uv偏移 长宽应当适配屏幕
				//float2 uvOffset=tangnentNormal.xy*_FlowStrength;
				//世界空间改为xz
				float2 uvOffset=worldNormal.xz*_FlowStrength;
				uvOffset.y*=_CameraDepthTexture_TexelSize.z*abs(_CameraDepthTexture_TexelSize.y);
        
				//齐次除法得到透视的uv坐标
				float2 uv=(screenPos.xy+uvOffset)/screenPos.w;
				#if UNITY_UV_STARTS_AT_TOP
					if (_CameraDepthTexture_TexelSize.y < 0) {
						uv.y = 1 - uv.y;
					}
				#endif
				//采样深度 得到深度差
				float backgroundDepth=LinearEyeDepth(tex2D(_CameraDepthTexture,uv));
				float surfaceDepth=UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
				float waterDepth=backgroundDepth-surfaceDepth;
        
				//水深为负数表明物体在水面之上，应当抹去法向偏移 重新计算
				uvOffset*=saturate(waterDepth);//负数就归0了，顺便水深0-1还可以有个过渡
				uv=(screenPos.xy+uvOffset)/screenPos.w;
				#if UNITY_UV_STARTS_AT_TOP
					if (_CameraDepthTexture_TexelSize.y < 0) {
						uv.y = 1 - uv.y;
					}
				#endif
				backgroundDepth=LinearEyeDepth(tex2D(_CameraDepthTexture,uv));
				surfaceDepth=UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
				waterDepth=backgroundDepth-surfaceDepth;
				//采样贴图
				float3 bgCol=tex2D(_RefractionTexture,uv).rgb;
				//根据水深模拟水的折射强度
				float fogFactor=exp2(-waterDepth*_WaterDensity);
				float3 finalCol=lerp(_WaterColor,bgCol,fogFactor);
				return finalCol;
			}
			//计算反射颜色 默认贴图名为_ReflectionTexture
			float3 ReflectionColor(float4 screenPos,float3 worldNormal)
			{
				//法线uv偏移 长宽应当适配屏幕
				//float2 uvOffset=tangnentNormal.xy*_FlowStrength;
				//世界空间，扰乱该为xz
				float2 uvOffset=worldNormal.xz*_FlowStrength;
				uvOffset.y*=_CameraDepthTexture_TexelSize.z*abs(_CameraDepthTexture_TexelSize.y);
        
				//齐次除法得到透视的uv坐标
				float2 uv=(screenPos.xy+uvOffset)/screenPos.w;
				#if UNITY_UV_STARTS_AT_TOP
					if (_CameraDepthTexture_TexelSize.y < 0) {
						uv.y = 1 - uv.y;
					}
				#endif
				float3 reflectCol=tex2D(_ReflectionTexture,uv);
				return reflectCol;
			}
    
			float Fresnel(float F0,float3 viewDir,float3 halfDir)
			{//schlick
				return F0+(1-F0)*pow((1-dot(viewDir,halfDir)),5);
			}
		//--------------------------------------------------------------    

		//-----------------------水体流动--------------------------------
 
			//根据uv采样流向，再根据流向和时间扰乱uv
			float2 DirectionalFlowUV(float2 uv,float3 flowVectorAndSpeed,float Tile,float time,out float2x2 roation)
			{
				//将流体方向转换为旋转矩阵来旋转uv；
				float2 dir=normalize(flowVectorAndSpeed.xy);
				//用于修改导数，一个点旋转后，导数表示的法线方向应旋转，比如原来是0,1旋转90度后应指向1,0
				roation=float2x2(dir.y,dir.x,-dir.x,dir.y);
				uv.xy=mul(float2x2(dir.y,-dir.x,dir.x,dir.y),uv);
				uv.y-=time*flowVectorAndSpeed.z;
				return uv*Tile;
			}
    
			//将贴图的导数映射回[-1,1]
			float3 UnpackDerivativeHeight (float4 textureData) {
					float3 dh = textureData.agb;
					dh.xy = dh.xy * 2 - 1;
					return dh;
			}
		
			//流向贴图每个像素的流向不连续采样的结果是破碎的，因此水面分成多个小块，每一块区域用同一个uv值采样流向
			//网格分布 _GridResolution
			float3 FlowCell(float2 uv,float2 offset,float time,bool gridB){
				float2 shift = 1 - offset;
				shift *= 0.5;//让采样在中心点
				offset*=0.5;//错开边缘的瑕疵线
				if(gridB){
					offset+=0.25;
					shift-=0.25;
				}
				//块状uv坐标 流向纹理采样
				float2 uvTiled=(floor(uv*_GridResolution+offset)+shift)/_GridResolution;
				float3 flow=tex2D(_FlowMap,uvTiled).rgb;
				flow.xy=flow.xy*2-1;
				flow.z*=_FlowStrength;
				float tiling = flow.z *_TilingModulated+ _Tile;//流向越快，缩放越大，波浪越大
        
				//得到经流向扭曲后的uv坐标
				float2x2 derivRotation;
				//随便加个offset打乱一下重复
				float2 uvFlow = DirectionalFlowUV(uv+offset,flow,tiling,time,derivRotation);
        
				//采样主贴图 导数和高
				float3 dh = UnpackDerivativeHeight(tex2D(_DerivHeightMap, uvFlow));//这里只能确保采样位置的匹配，不会修改内部的数据
				dh.xy=mul(derivRotation,dh.xy);//导数也做对应的旋转
				dh *= flow.z * _HeightScaleModulated + _HeightScale;//强度
				return dh;
			}
    
			//每个cell混合周围cell，得到最终网格值，gridB用于创造一点偏移，从而得到另一个网格结果，混合两者降低边缘瑕疵
			float3 FlowGrid(float2 uv,float time,bool gridB)
			{
				//混合相邻块
				float3 dhA=FlowCell(uv,float2(0,0),time,gridB);
				float3 dhB=FlowCell(uv,float2(1,0),time,gridB);
				float3 dhC=FlowCell(uv,float2(0,1),time,gridB);
				float3 dhD=FlowCell(uv,float2(1,1),time,gridB);
				//计算混合权值
				float2 t=uv*_GridResolution;
				if(gridB){t+=0.25;}//偏移第二次网格的位置
				t= abs(2 * frac(t) - 1);
				float wA = (1 - t.x) * (1 - t.y);
				float wB = t.x * (1 - t.y);
				float wC = (1 - t.x) * t.y;
				float wD = t.x * t.y;
				float3 dh=wA*dhA+wB*dhB+wC*dhC+wD*dhD;
				return dh;
			}
		//-----------------------------------------------------

		//------------------------波浪------------------------------
			float3 GerstnerWave (float4 wave, float wavespeed,float3 p, inout float3 tangent, inout float3 binormal){
					float steepness=wave.z;
					float wavelength=wave.w;
            
            
					float k=UNITY_PI*2/(wavelength);
					float a=(steepness/k);//通过波长和表面压力配置值来得到amplitude  
					float c=sqrt(9.8/k);//速度同样借此推导 
					//偏移与xy方向对齐
					float2 d=normalize(wave.xy).xy;
					float f=k*(dot(d,p.xz)-c*_Time.y*wavespeed);
					float3 offset=float3(
					d.x*a*cos(f),
					a*sin(f),
					d.y*a*cos(f)
					);
					//计算导数得到切线和次切线并推出法线  _Steepness=k*a
					tangent += float3(
						-d.x * d.x * (steepness * sin(f)),
						d.x * (steepness * cos(f)),
						-d.x * d.y * (steepness * sin(f))
					);
					binormal += float3(
						-d.x * d.y * (steepness * sin(f)),
						d.y * (steepness * cos(f)),
						-d.y * d.y * (steepness * sin(f))
					);
					return offset;
				}
		//--------------------------------------------------

		//--------------------泡沫----------------------------
			float3 FoamColor(float4 screenPos,float2 FoamUV)
			{
				//未经法线扰乱的深度
				float2 uv=(screenPos.xy)/screenPos.w;
				#if UNITY_UV_STARTS_AT_TOP
					if (_CameraDepthTexture_TexelSize.y < 0) {
						uv.y = 1 - uv.y;
					}
				#endif
				float backgroundDepth=LinearEyeDepth(tex2D(_CameraDepthTexture,uv));
				float surfaceDepth=UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
				float waterDepth=backgroundDepth-surfaceDepth;
        
				//一条依附边缘
				float factor1=1-smoothstep(_Foam1Range,_Foam1Range+0.2,waterDepth);
				//一条移动
				float time=-frac(_Time.y*_Foam2Speed);
				float offset=time*_Foam2Range;//(0-_Foam2Range)的偏移量
				float fade=sin(frac(_Time.y*_Foam2Speed)*3.14);//中间最明显
				float factor2=step(_Foam1Range+_Foam2Range+0.12+offset,waterDepth)*step(waterDepth,_Foam1Range+_Foam2Range+0.15+offset);
				float factor=factor1+factor2*fade*0.5;
				float3 foamCol=factor*tex2D(_FoamTexture,FoamUV*10).r;
				return foamCol;
			}


            
            v2f vert(a2v v){
                v2f o;
                
                #if defined(_WAVE_A_OPEN)||defined(_WAVE_B_OPEN)||defined(_WAVE_C_OPEN)
                    float3 gridPoint=v.vertex.xyz;
                    float3 tangentG=float3(1,0,0);
                    float3 binormalG=float3(0,0,1);
                    float3 p=gridPoint;
                    #if defined(_WAVE_A_OPEN)
                        p+=GerstnerWave(_WaveA,_WaveASpeed,gridPoint,tangentG,binormalG);
                    #endif
                    #if defined(_WAVE_B_OPEN)
                        p+=GerstnerWave(_WaveB,_WaveBSpeed,gridPoint,tangentG,binormalG);
                    #endif
                    #if defined(_WAVE_C_OPEN)
                        p+=GerstnerWave(_WaveC,_WaveCSpeed,gridPoint,tangentG,binormalG);
                    #endif
                    float3 normal=normalize(cross(binormalG,tangentG));
                    v.vertex.xyz=p;
                    v.normal=normal;
                #endif
                
                
                o.pos=UnityObjectToClipPos(v.vertex);
                o.ScreenPos=ComputeScreenPos(o.pos);//一定要在顶点函数里计算，然后让插值器插值，在片元函数里得到的o.pos可能已经裁减空间的pos了
                o.uvNF.xy=TRANSFORM_TEX(v.texcoord,_DerivHeightMap);
                o.uvNF.zw=TRANSFORM_TEX(v.texcoord,_FoamTexture);
                //对于折射的扰乱我们用的是法向量，如果使用切线空间法向量，那么只有法线贴图会影响扰乱
                //所以我们选择世界空间计算光照
                //TANGENT_SPACE_ROTATION; //得到切线空间矩阵rotation
                //o.TangentLightDir=mul(rotation,ObjSpaceLightDir(v.vertex));
                //o.TangentViewDir=mul(rotation,ObjSpaceViewDir(v.vertex));
                
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z,worldPos.z);
                
                return o;
            }

            float4 frag(v2f i):SV_Target{
                //得用UnityWorldxxxxDir(要求世界空间的顶点位置) 不能用WorldxxxxDir(要求对象空间的顶点位置)
                //float3 lightDir=normalize(i.TangentLightDir);
                //float3 viewDir=normalize(i.TangentViewDir);
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 halfDir=normalize(lightDir+viewDir);
                
                
                //扰乱法线的uv，模拟流动效果
                float time=_Time.y*_FlowSpeed;
                float2 waveUV=i.uvNF.xy;
                float3 dh = FlowGrid(waveUV, time, false);
			    #if defined(_DUAL_GRID)
				dh = (dh + FlowGrid(waveUV, time, true)) * 0.5;
			    #endif
			    
                float3 normal=normalize(float3(dh.xy, 1));
                //切线空间转至世界空间
                normal = normalize(half3(dot(i.TtoW0, normal), dot(i.TtoW1, normal), dot(i.TtoW2, normal)));

                
                float waterDepth;
                //采样折射
                float3 refrCol=RefractionColor(i.ScreenPos,normal);
                //采样反射
                float3 reflCol=ReflectionColor(i.ScreenPos,normal);
                //泡沫采样
                float3 foamCol=FoamColor(i.ScreenPos,i.uvNF.zw);
                
                //漫反射
                //float3 diffuse=_LightColor0.rgb*_Color*saturate(dot(normal,lightDir));
                //高光
                float3 specular=_LightColor0.rgb*pow(saturate(dot(halfDir,normal)),_Gloss)*0.1;
                
                
                float3 finalCol=lerp(refrCol,reflCol,saturate(Fresnel(_Fresnel,viewDir,lightDir)))+specular+foamCol;
                return float4(finalCol,1);
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
}
