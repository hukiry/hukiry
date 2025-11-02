Shader "YueChuan/RimLight/RimLightDiffuseOnePass" 
{
    Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "White" {}
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_RimColor ("Edge Color", Color) = (1.0,1.0,1.0,1.0)
	}
     SubShader 
	 {
         Tags { "RenderType" = "Opaque"}
         CGPROGRAM
         #pragma surface surf Lambert
         
         uniform sampler2D _MainTex ;
         uniform fixed4 _RimColor; 
         uniform fixed4 _Color;  
         uniform half _IsRimLight;
         uniform half _Attenuation;
         
         struct Input 
         {
              half2 uv_MainTex;
			  float3 worldNormal;
			  float3 worldPos;
         };
                 
         void surf (Input input, inout SurfaceOutput o) 
         {
			 float3 rimColor = float3(0, 0, 0);
			 if (_IsRimLight)
			 {
				 float3 vEyeDir = normalize(_WorldSpaceCameraPos.xyz - input.worldPos.xyz);
				 rimColor = pow((1.0 - dot(vEyeDir, input.worldNormal.xyz)), 1) * _RimColor * _Attenuation;
			 }

              o.Albedo = tex2D (_MainTex, input.uv_MainTex).rgb * _Color + rimColor;
         }
         ENDCG
    }
	Fallback "Diffuse"
}
