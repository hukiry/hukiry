//顶点动画圆环波纹效果
Shader "Sbin/FragmentAnimShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}//主纹理
        _F("F",Range(1,30))=10//π的K 光环缩放
        _Alpha("Alpha",Range(0,0.1))=0.01
        _Radius("Radius",Range(0,1))=0//圆的半径
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            sampler2D _MainTex;
            float _F;//控制速度 
            float _Alpha;
            float _Radius;//控制半径 
 
            struct v2f{
                float4 pos:POSITION;
                float2 uv:TEXCOORD0;
            };
 
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.texcoord.xy;
                return o;
            }
 
            fixed4 frag (v2f v) : COLOR
            {
                float dis = distance(v.uv,float2(0.5,0.5));//距离中心点位置

                _Alpha *=saturate(1-dis/_Radius);//计算半径范围内，波动

                 float scale = _Alpha*sin(-dis*3.14*_F+ _Time.y);//-dis*3.14*_F向外波动，dis*3.14*_F向内波动 K*πR 半径*π*偏移数
         
                fixed4 col = tex2D(_MainTex, v.uv) +saturate(scale)*100;//方法saturate（），限制值的范围【0到1】
                return col;
            }
            ENDCG
        }
    }
}
