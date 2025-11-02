//顶点动画
Shader "Custom/Grass" {
    Properties {
        _MainTex ("Grass Texture", 2D) = "white" {}
        _TimeScale ("Time Scale", float) = 1 //时间缩放
    }
 
    SubShader{
        Tags{"Queue"="Transparent" "RenderType"="Opaque" "IgnoreProject"="True"}
        Pass{
            Tags{"LightMode"="ForwardBase"}
 
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            sampler2D _MainTex;
            half _TimeScale;
 
            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
             
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
 
 
            v2f vert(a2v v){//每帧调用一次
                v2f o;
                float4 offset = float4(0,0,0,0);
				//正玄 y=sinX X∈[0,2π弧度]对应[0,360度]；clamp()值的范围限制clamp(v.texcoord.y-0.5, 0, 1)
                offset.x = sin(3.1416 * _Time.y * clamp(v.texcoord.y-0.5, 0, 1))  * _TimeScale;
				//顶点模型，观察，投影裁剪，添加顶点偏移量
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex + offset);
                o.uv = v.texcoord.xy;//输入纹理坐标
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target{//输出纹理颜色
                return tex2D(_MainTex, i.uv);
            }
 
            ENDCG
        }
    }
    FallBack Off
}