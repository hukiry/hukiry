Shader "YueChuan/Others/DiffuseWithFlash" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _Color("Color", Color) = (1.0,1.0,1.0,1.0)
        _Flash("Flash (RGB)", 2D) = "black" {}
        _FlashColor("Flash Color", Color) = (1.0,1.0,1.0,1.0)
        _FlashSpeed("Flash Speed", Vector) = (4, 0, 0, 4)
        _FlashIntensity("Flash Intensity", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
        sampler2D _Flash;
        fixed4 _FlashColor;
        fixed4 _FlashSpeed;
        fixed4 _Color;
        half _FlashIntensity;

		struct Input {
			float2 uv_MainTex;
		};

        fixed4 FlashLight(float2 uv, half mask)
        {
            half2 flashUV = fmod(uv + (_FlashSpeed.xy + _FlashSpeed.zw) * _Time.x, 1.0);
            fixed4 flash = tex2D(_Flash, uv + flashUV);

            flash = flash * flash * _FlashColor * mask * _FlashIntensity;
            return flash;
        }

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb * _Color;
			o.Alpha = c.a;
            o.Emission = FlashLight(IN.uv_MainTex, c.a);
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
