Shader "YueChuan/Character/CharacterMirageHigh"
{
    Properties 
	{
		_Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Base (RGB)", 2D) = "White" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"
   
    uniform sampler2D _MainTex;
    uniform half4 _MainTex_ST;
    
    uniform fixed4 _Color;
    uniform half _EmissionAmount;
    
        
    struct VS_OUTPUT
    {
        float4 v4Position : SV_POSITION;
        float4 v4ProjPos : TEXCOORD0;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
        VS_OUTPUT output = (VS_OUTPUT)0;
       
        float3 v3NewPos = input.vertex.xyz + input.normal * 0.3;
        output.v4Position = mul(UNITY_MATRIX_MVP, float4(v3NewPos,1.0));
        output.v4ProjPos = ComputeScreenPos(output.v4Position);
        return output;
    }

    fixed4 MainPS(VS_OUTPUT input) : COLOR 
    {
        fixed4 v4BaseColor = tex2Dproj(_MainTex, UNITY_PROJ_COORD(input.v4ProjPos)) * _Color;
        return fixed4(v4BaseColor.rgb * (_EmissionAmount + 1),v4BaseColor.a);
    }
    
   // float4 MainOCPS(VS_OUTPUT input) : COLOR 
  //  {
   //     half2 UV = 0.5 * input.v4ProjPos.xy/input.v4ProjPos.w + 0.5;
   //     #if UNITY_UV_STARTS_AT_TOP
    //    UV.y = 1 - UV.y;
    //    #endif
    //    fixed4 v4BaseColor = tex2D(_MainTex,UV) * _Color;	
    //    return fixed4(fixed3(0.5, 1.0, 0.9),v4BaseColor.a);
  //  }
    
    ENDCG

    SubShader
	{
		Tags {"RenderType"="Transparent" "Queue"="Transparent+900" "LightMode" = "Vertex"}
		LOD 200
		
		//Pass
		//{
		//	Cull Back 
		//	ZTest Greater
		//	ZWrite off
			//Blend SrcAlpha OneMinusSrcAlpha

		//	CGPROGRAM
       //     #pragma vertex MainVS
        //    #pragma fragment  MainOCPS
        //    #pragma target 2.0
		//	ENDCG
		//}

	    Pass 
        {
			ZTest Less
            Cull Back 
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM           
            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
			ENDCG
        }
   }
}
