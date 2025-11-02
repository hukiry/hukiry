Shader "Hidden/Mosaic"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TileSize("Tile Size", Range(0.001,1)) = 0.05
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
			 sampler2D _MainTex;
			  float4 _MainTex_ST;
            fixed _TileSize;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }
            


            fixed4 frag (v2f i) : SV_Target
            {                
                i.uv.x =ceil(i.uv.x/_TileSize)*_TileSize;
                i.uv.y =ceil(i.uv.y/_TileSize)*_TileSize;
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}