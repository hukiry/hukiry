Shader "MyCustom/MyShader01" {
	Properties {//属性
	_MyColor("MYColor",color) = (1,0,0,1)
	_Ambient("MyAmbient",color) = (0.3,0.3,0.3,1)
	_Specular("MySpecular",color) = (0.3,0.3,0.3,1)
	_Shininess("MyShininess",range(0,8)) = 4 
	_Emission("MyEmission",color) = (1,1,1,1)
	_MainTexture("MainTexture",2D) = ""
	}
	SubShader {//Shader算法
		Pass//存储以及处理图像的色彩
		{
			//Color(1,0,0,1)//()使用固定值
			//color[_MyColor]//[]使用参数值
			material
			{
				//漫反射,必须跟灯光配合，将光打到物体表面反射光，我们才能看到物体
				diffuse[_MyColor]
				ambient[_Ambient]//环境光
				specular[_Specular]//高光反射
				shininess[_Shininess]//设置高光反射区域以及强烈程度
				emission[_Emission]//自发光
			}
			lighting on //启动光照
			separateSpecular on//启动高光效果

			setTexture[_MainTexture]//设置纹理图片
			{
				combine Texture*previous double//与之前材质效果混合
			}
		}
	}
}
