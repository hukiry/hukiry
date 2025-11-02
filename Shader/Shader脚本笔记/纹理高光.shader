Shader "LT/RampTexture"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _RampTex("Ramp Tex",2D) = "white" {}    //渐变纹理
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }//定义该Pass在光照流水线中的角色光照模式注意要设置为Forward
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _RampTex;
            fixed4 _Specular;
            float4 _RampTex_ST;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(_Object2World,v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _RampTex);   //内置的宏计算平铺和偏移位置
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal =normalize(i.worldNormal);
                fixed3 worldLightDir =normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;
                
                //法线和方向和光照方向的点积做一次0.5倍的缩放和一个0.5大小的偏移来计算兰伯特部分halfLambert,得到结果在【0，1】之间
                fixed halfLambert = 0.5 *dot(worldNormal,worldLightDir) +0.5;
                //用halfLambert构建一个纹理坐标，并对这个纹理坐标对_RampTex进行采样。
                //由于_RampTex实际是一个一维纹理（纵轴方向上颜色不变），所以纹理坐标的UV方向我们都使用了halfLambert，
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;
                //漫反射颜色 = 渐变纹理采样得到的颜色 * 材质颜色
                fixed3 diffuse  = _LightColor0 * diffuseColor ;

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
            
                fixed3 specular = _LightColor0.rbg * _Specular.rgb *pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                fixed4 col = fixed4( diffuse+  specular + ambient,1.0);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Specular"
}