Shader "YueChuan/Others/FillStencilZeroDark"
{
//	Properties 
//	{
//		_MainTex ("Base (RGB)", 2D) = "white" {}
//	}
	SubShader
	{
		Tags { "Queue"="Transparent+998" }
		LOD 200
		
		Pass 
        {
        	ZWrite Off
			//ZTest Always
			Blend SrcAlpha OneMinusSrcAlpha
			
			Stencil
			{
                Ref 0
                Comp Equal
                Pass Keep
                ZFail Keep
            }
            
            //Color (0,0,0,0.6)
			
			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment  MainPS
            #pragma target 2.0
           
            #include "UnityCG.cginc"
            
            uniform sampler2D _MainTex;
            
            struct VS_OUTPUT
            {
                float4 v4Position : SV_POSITION;
                float2 v2Texcoord : TEXCOORD0;
            };

            VS_OUTPUT MainVS(appdata_base input)
            {
                VS_OUTPUT output = (VS_OUTPUT)0;
                output.v4Position = mul (UNITY_MATRIX_MVP, input.vertex);
				output.v2Texcoord = input.texcoord;
               
                return output;
            }

            float4 MainPS(VS_OUTPUT input) : COLOR 
            {
				float4 color = float4(0, 0, 0, 0.9f);
				return color;
            }

            ENDCG
        }
        
//        Pass
//        {
//        	ZWrite Off
//			ZTest Always
//			
//			Stencil
//			{
//                Ref 1
//                Comp Equal
//                Pass Keep
//                ZFail Keep
//            }
//            
//            //Color (1,0,0,0)
//			
//			CGPROGRAM
//
//            #pragma vertex MainVS
//            #pragma fragment  MainPS
//            #pragma target 2.0
//           
//            #include "UnityCG.cginc"
//            
//            uniform sampler2D _MainTex;
//            
//            struct VS_OUTPUT
//            {
//                float4 v4Position : SV_POSITION;
//                float2 v2Texcoord : TEXCOORD0;
//            };
//
//            VS_OUTPUT MainVS(appdata_base input)
//            {
//                VS_OUTPUT output = (VS_OUTPUT)0;
//                output.v4Position = mul (UNITY_MATRIX_MVP, input.vertex);
//				output.v2Texcoord = input.texcoord;
//               
//                return output;
//            }
//
//            float4 MainPS(VS_OUTPUT input) : COLOR 
//            {
//				float4 color = tex2D(_MainTex, input.v2Texcoord);
//				return color;
//            }
//
//            ENDCG
//        }
	} 
}
