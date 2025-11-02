Shader "Unlit/Flame"  
{  
    Properties{  
		[Toggle]_Open("显示MainTex",float)=1 
		_MainTex("MainTex",2D)=""{}

		[Space(5)]_fireColor("火焰颜色",color)=(1,0.5,0.1,1)   
		[Space(5)] _fireDownColor	("火底颜色",color)=(0.1,0.5,1,1)   
		[Space(5)] _backColor("背景颜色",color)=(0,0,0,0) 
		[Space(5)] _powValue("powValue",Range(1,10))=4
		[Space(5)]_lerpY	("火焰底火插值",Range(0.001,0.2))=0.02
		[HideInInspector] _lerpAdd("火焰底火插值加量",Range(1,10))=2
		[Space(15)] 
		_fireWidth("火焰宽度",Range(-3,3))=1.5
		_fireHeight("火焰高度",Range(-2,-0.01))=-1.5
		[Space(15)]
		[Enum(UnityEngine.Rendering.BlendMode)]_srcAlpha("Blend SrcAlpha",float)  =6
		[Enum(UnityEngine.Rendering.BlendMode)]_dstAlpha("Blend DstAlpha",float)  =1
		 
    }  
 
    CGINCLUDE      
    #include "UnityCG.cginc"
	//定义_Open，必须大写+“_ON” 
	#pragma shader_feature _OPEN_ON   
    #pragma target 3.0        

		sampler2D _MainTex;
	float4 _MainTex_ST;
    float4 main(in float2 uv);  
  
    struct v2f {      
        float4 pos : SV_POSITION;      
        float2 uv : TEXCOORD0;  
		float2 uv2 : TEXCOORD1;     
    };                
  	struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
			float2 uv2 : TEXCOORD1; 
        };
    v2f vert(appdata v) {    
        v2f o;  
        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);  
        o.uv = v.uv;  //计算屏幕颜色 ComputeScreenPos(o.pos)
		o.uv2=TRANSFORM_TEX(v.uv2,_MainTex);
        return o;  
    }  
	
	fixed4 frag2(v2f i) : SV_Target {   //纹理采样
		fixed4 col=tex2D(_MainTex,i.uv2);
		#if !_OPEN_ON
		col.a=0;
		#endif
        return col;
    }    
  
    fixed4 frag(v2f i) : SV_Target {   
        float2 uv = i.uv;
        return main(uv); 
    }  
  
  
    float noise(float3 p) 
	{  
		float3 i = floor(p);  
		float4 a = dot(i, float3(1., 57., 21.)) + float4(0., 57., 21., 78.);  
		float3 f = cos((p-i)*acos(-1.))*(-.5)+.5;  
		a = lerp(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);  
		a.xy = lerp(a.xz, a.yw, f.y);  
		return lerp(a.x, a.y, f.z);  
	}  
  
	float sphere(float3 p, float4 spr)  
	{  
		return length(spr.xyz-p) - spr.w;  
	}  
  
	float flame(float3 p)  
	{  
		float d = sphere(p*float3(1.,.5,1.), float4(.0,-1.,.0,1.));  
		return d + (noise(p+float3(.0,_Time.y*2.,.0)) + noise(p*3.)*.5)*.25*(p.y) ;  
	}  
  
	float scene(float3 p)  
	{  
		return min(100.-length(p) , abs(flame(p)) );  
	}  
  
	float4 raymarch(float3 org, float3 dir)  
	{  
		float d = 0.0, glow = 0.0, eps = 0.02;  
		float3  p = org;  
		bool glowed = false;  
      
		for(int i=0; i<64; i++)  
		{  
			d = scene(p) + eps;  
			p += d * dir;  
			if( d>eps )  
			{  
				if(flame(p) < .0)  
					glowed=true;  
				if(glowed)  
					glow = float(i)/64.;  
			}  
		}  
		return float4(p,glow);  
	}  

  	float4 _fireColor;
	float4 _fireDownColor;
	float4 _backColor;
	float _powValue,_lerpY,_lerpAdd,_fireWidth,_fireHeight;

	float4 main(in float2 uv)  
	{  
		float4 fragColor;  
		float2 v = uv-float2(0.5,0.5);//计算中心点

		float3 org = float3(0, -2,4);  

		float3 dir = normalize(float3(v.x*_fireWidth, -v.y, _fireHeight));  //(v.x*1.6, -v.y, -1.5)
      
		float4 p = raymarch(org, dir);   
      
		float4 col = lerp(_fireColor, _fireDownColor, p.y*_lerpY);  
      
		fragColor = lerp(_backColor, col, pow(p.w*_lerpAdd,_powValue));  
	
		return fragColor;  
	}  
  
    ENDCG      
  
    SubShader {  
	   			
        Pass {  
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM      	
            #pragma vertex vert      
            #pragma fragment frag2      
            ENDCG      
        }  

        Pass {  
			Blend [_srcAlpha] [_dstAlpha]
			Cull Off
			Lighting Off
			ZWrite Off
            CGPROGRAM      	
            #pragma vertex vert      
            #pragma fragment frag      
            #pragma fragmentoption ARB_precision_hint_fastest   
            ENDCG      
        }  
   
    }       
    FallBack Off      
}