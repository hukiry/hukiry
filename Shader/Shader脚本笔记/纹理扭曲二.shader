Shader "Custom/SwirlShader" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        //_Cutout("透明剔除值",Float) = 0.5
        _Radius("Radius", Float) = 5
        _SwirlValue("SwirlValue", Float) = 1
    }
    SubShader {
	 Tags { "RenderType"="Transparent" "Queue"="Transparent"}  
        Pass {
		
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            fixed _Radius;
            fixed _SwirlValue;

           // fixed _Cutout;
            struct vin_vct 
            {
                fixed4 vertex : POSITION;
                fixed2 texcoord : TEXCOORD0;
            };

            struct v2f_vct
            {
                fixed4 vertex : SV_POSITION;
                fixed2 texcoord : TEXCOORD0;
            };

            v2f_vct vert(vin_vct v)
            {
                v2f_vct o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }

            fixed4 frag(v2f_vct i) : SV_Target 
            {
                fixed2 center = fixed2(0.5,  0.5);//计算扭曲区域的中心点位置
              
                fixed2 targetPlace = i.texcoord  - center;  //计算得到要扭曲的片段距离中心点的距离

                fixed dis = length(targetPlace);
                
                if(dis < _Radius)//当距离比需要扭曲的半径小的时候，计算扭曲
                {
                    fixed percent = (_Radius - dis) / _Radius; //计算扭曲的程度,慢慢向边缘减弱扭曲,当它恒为1的时候，是一个正圆
                    
                    fixed delta = percent * _SwirlValue;//根据扭曲程度计算因子，还可以改写为_Time的值让它一直转
                 
                    fixed _sin = sin(delta);   //得到在轴上的值
					
                    fixed _cos = cos(delta);
					// fixed2(dot(targetPlace, fixed2(_cos, -_sin)), dot(targetPlace, fixed2(_sin, _cos)));两种算法一样
                    targetPlace =fixed2(targetPlace.x*_cos-targetPlace.y*_sin,targetPlace.x*_sin+targetPlace.y*_cos);
                }
                
                targetPlace += center;//把计算的值偏移回中心点

                fixed4 c = tex2D(_MainTex, targetPlace);// * i.color;
                //clip(c.a - _Cutout);
                return c;
            }
           ENDCG
        }
    }
    FallBack "Diffuse"
}