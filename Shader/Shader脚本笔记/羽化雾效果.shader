Shader "ShaderDemo/feather"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _size("size",Vector) = (0.2,0.2,0,0)
        _scale("scale",Range(0,1)) = 0.01
        _alpha("alpha",Range(0,1))=1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }//使用透明渲染

        Blend SrcAlpha OneMinusSrcAlpha//开启透明混合

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)//输入雾数据
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;//主纹理
            float4 _MainTex_ST;

            float4 _size;//羽化尺寸
            float _scale;//缩放雾大小
            float _alpha;//雾的透明
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);//从顶点输出雾数据
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);//采样主纹理颜色
                // apply fog 使用雾数据
                UNITY_APPLY_FOG(i.fogCoord, col);

                fixed2 size = fixed2(_size.x,_size.y);
                fixed2 dis2 = (fixed2(0.5,0.5) - i.uv);//取中心点


                float dx = dis2.x/size.x;//
                float dy = dis2.y/size.y;

                float a = sqrt(dx*dx+dy*dy);//计算到圆心的距离
                float b = sqrt(pow(size.x+1,2) + pow(size.y+1,2));//xy偏移一个单位，计算到圆心的距离
                col.a = 1-a+b;

                col.r =clamp(col.r+a*_scale,0,1);
                col.g =clamp(col.g+a*_scale,0,1);
                col.b =clamp(col.b+a*_scale,0,1); 

                col.a *= _alpha;
                return col;
            }
            ENDCG
        }
    }
} 