Shader "Hidden/Unlit/Transparent Colored Sequence 1"
{
    Properties
    {
        _MainTex("Base (RGB), Alpha (A)", 2D) = "black" {}
    }

    SubShader
    {
        LOD 200

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog { Mode Off }
            Offset -1, -1
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag			
    #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
            float2 _ClipArgs0 = float2(1000.0, 1000.0);

            float4 _SpriteCenterOffset;
            float4 _SpriteSize;
            float _ColorMultiply;
            float4 _Color = float4(1.0, 1.0, 1.0, 1.0);

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
                float2 worldPos : TEXCOORD1;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.texcoord = v.texcoord + _SpriteCenterOffset.xy - (_SpriteSize.xy - _SpriteSize.zw) * 0.5f;

                float3 worldPos = mul(_Object2World, v.vertex);
                o.worldPos = worldPos.xy * _ClipRange0.zw + _ClipRange0.xy;
                return o;
            }

            fixed4 frag(v2f IN) : COLOR
            {
                // Softness factor
                float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs0.xy;

                fixed4 col = tex2D(_MainTex, IN.texcoord) * _Color * _ColorMultiply;

                col.a *= clamp(min(factor.x, factor.y), 0.0, 1.0);
                return col;
            }
            ENDCG
        }
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog{ Mode Off }
            Offset -1, -1
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMaterial AmbientAndDiffuse

            SetTexture[_MainTex]
            {
                Combine Texture * Primary
            }
        }
    }
}
