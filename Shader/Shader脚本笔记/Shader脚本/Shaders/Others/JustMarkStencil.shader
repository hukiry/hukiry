Shader "YueChuan/Others/JustMarkStencil"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass 
        {
        	ZWrite Off
			ColorMask 0
			
			// 在模板缓冲区写入1
			Stencil
			{
                Ref 1
                Comp always
                Pass replace
                ZFail keep
            }
			
			Color (1,1,0,0)
        }
	} 
}
