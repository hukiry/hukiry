//纹理透明遮罩和溶解
Shader "Custom/AlphaMask" {
    Properties
     {
     _Color ("Main Color", Color) = (1,1,1,1)
     _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
     _MaskTex ("Mask (A)", 2D) = "white" {}
     _Progress ("Progress", Range(0,1)) = 0.5
     }
     Category
     {
         Lighting Off
         ZWrite Off
         Cull back
         Fog { Mode Off }
         Tags {"Queue"="Transparent" "IgnoreProjector"="True"}
         Blend SrcAlpha OneMinusSrcAlpha
         SubShader
         {
             Pass
             {
                 CGPROGRAM
                 #pragma vertex vert
                 #pragma fragment frag
                    sampler2D _MainTex;
                 sampler2D _MaskTex;
                 fixed4 _Color;
                 float _Progress;
                 struct appdata
                 {
                     float4 vertex : POSITION;
                     float4 texcoord : TEXCOORD0;
                 };
                 struct v2f
                 {
                        float4 pos : SV_POSITION;
                     float2 uv : TEXCOORD0;
                 };
                 v2f vert (appdata v)
                 {
                     v2f o;
                     o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                     o.uv = v.texcoord.xy;
                     return o;
                }
                half4 frag(v2f i) : COLOR
				{
					//要开启混合透明，关闭深度写入，剔除背面，关闭雾，关闭灯光，使用透明队列
					fixed4 c = _Color * tex2D(_MainTex, i.uv);//主纹理
					fixed ca = tex2D(_MaskTex, i.uv).a;//遮罩纹理
					c.a *= ca >= _Progress ? 0 : 1;
					//如果遮罩纹理某个像素点的a通道大于指定值，那么对应主纹理的像素点透明，否则正常显示
					return c;



				}
                 ENDCG
             }
         }
         SubShader
         {         
              AlphaTest LEqual [_Progress] 
               Pass 
               { 
                  SetTexture [_MaskTex] {combine texture} 
                  SetTexture [_MainTex] {combine texture, previous} 
               } 
         }
        
     }
     Fallback "Transparent/VertexLit"
 }

 //根据半径透明遮罩计算 
               //if(f.texcoord.x<0.5 && f.texcoord.y>0.5)  
               // {  
               //     float2 r;  
               //     r.x=0.5-f.texcoord.x;  
               //     r.y=f.texcoord.y-0.5;  
               //     if(length(r)>_Radius)//以r.x、r.y为两直角边长度，计算斜边长度  
               //     {  
               //         return fixed4(1,1,1,0);  
               //     }  
               //     else  
               //     {  
               //         return color;  
               //     }  
               // }  
               // //左下方区域  
               // else if(f.texcoord.x<0.5 && f.texcoord.y<0.5)  
               // {  
               //     float2 r;  
               //     r.x=0.5-f.texcoord.x;  
               //     r.y=0.5-f.texcoord.y;  
               //     if(length(r)>_Radius)  
               //     {  
               //         return fixed4(1,1,1,0);  
               //     }  
               //     else  
               //     {  
               //         return color;  
               //     }  
               // }  
               // //右上方区域  
               // else if(f.texcoord.x>0.5 && f.texcoord.y>0.5)  
               // {  
               //     float2 r;  
               //     r.x=f.texcoord.x-0.5;  
               //     r.y=f.texcoord.y-0.5;  
               //     if(length(r)>_Radius)  
               //     {  
               //         return fixed4(1,1,1,0);  
               //     }  
               //     else  
               //     {  
               //         return color;  
               //     }  
               // }  
               // //右下方区域  
               // else if(f.texcoord.x>0.5 && f.texcoord.y<0.5)  
               // {  
               //     float2 r;  
               //     r.x=f.texcoord.x-0.5;  
               //     r.y=0.5-f.texcoord.y;  
               //     if(length(r)>_Radius)  
               //     {  
               //         return fixed4(1,1,1,0);  
               //     }  
               //     else  
               //     {  
               //         return color;  
               //     }  
               // }  