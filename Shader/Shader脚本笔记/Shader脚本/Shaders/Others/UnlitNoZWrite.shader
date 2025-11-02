Shader "YueChuan/Others/UnlitNoZWrite"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Background" }
		
		pass
		{
        	ZWrite Off
			Lighting Off
			
			SetTexture [_MainTex] { }	
        }
	} 
}
