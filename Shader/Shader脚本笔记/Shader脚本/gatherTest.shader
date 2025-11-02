Shader "Unlit/gatherTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UFlow("U Flow" , float) = 0
        _VFlow("V Flow" , float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		

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
                float2 uv       : TEXCOORD0;
                float4 vertex   : SV_POSITION;
            };

            sampler2D   _MainTex;
            float4      _MainTex_ST;

            float       _UFlow;
            float       _VFlow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float2 uv = i.uv-0.5;
 
                float2 polarUV = float2(frac(atan2(uv.x,uv.y)/3.14/2) , length(uv)*2); 
                fixed4 col = tex2D(_MainTex,polarUV + float2(_UFlow , _VFlow) * _Time.y);
                return col;
            }
            ENDCG
        }
    }
}
