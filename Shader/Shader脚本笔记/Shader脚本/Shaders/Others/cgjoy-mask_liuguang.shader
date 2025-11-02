// Shader created with Shader Forge v1.05 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.05;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:0,bsrc:0,bdst:1,culm:0,dpts:2,wrdp:True,dith:0,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:6406,x:33217,y:32577,varname:node_6406,prsc:2|emission-1439-OUT;n:type:ShaderForge.SFN_Tex2d,id:7421,x:32813,y:32582,ptovrint:False,ptlb:main,ptin:_main,varname:node_7421,prsc:2,tex:3d0d3b49e05655f42a4655fd3e068824,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:9089,x:32651,y:33005,ptovrint:False,ptlb:mask,ptin:_mask,varname:node_9089,prsc:2,tex:1a41dfb68a3f17e4087d89599a4e8300,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Panner,id:7898,x:32302,y:32793,varname:node_7898,prsc:2,spu:0,spv:0.2;n:type:ShaderForge.SFN_Tex2d,id:8161,x:32495,y:32793,ptovrint:False,ptlb:liudong,ptin:_liudong,varname:node_8161,prsc:2,tex:5725b38e5d0ada54a80240ba9cedafd8,ntxv:0,isnm:False|UVIN-7898-UVOUT;n:type:ShaderForge.SFN_Multiply,id:2377,x:32879,y:32901,varname:node_2377,prsc:2|A-5288-OUT,B-9089-RGB;n:type:ShaderForge.SFN_Add,id:1439,x:33018,y:32679,varname:node_1439,prsc:2|A-7421-RGB,B-2377-OUT;n:type:ShaderForge.SFN_Vector1,id:1796,x:32467,y:32654,varname:node_1796,prsc:2,v1:2;n:type:ShaderForge.SFN_Multiply,id:5288,x:32694,y:32767,varname:node_5288,prsc:2|A-1796-OUT,B-8161-RGB,C-773-RGB;n:type:ShaderForge.SFN_Color,id:773,x:32467,y:32501,ptovrint:False,ptlb:liuqv_color,ptin:_liuqv_color,varname:node_773,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:7421-9089-8161-773;pass:END;sub:END;*/

Shader "Shader Forge/long" {
    Properties {
        _main ("main", 2D) = "white" {}
        _mask ("mask", 2D) = "white" {}
        _liudong ("liudong", 2D) = "white" {}
        _liuqv_color ("liuqv_color", Color) = (0.5,0.5,0.5,1)
        _liudong2("liudong2", 2D) = "white" {}
        _liuqv_color2("liuqv_color2", Color) = (0.5,0.5,0.5,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _main; uniform float4 _main_ST;
            uniform sampler2D _mask; uniform float4 _mask_ST;

            uniform sampler2D _liudong; uniform float4 _liudong_ST;
            uniform float4 _liuqv_color;

            uniform sampler2D _liudong2; uniform float4 _liudong2_ST;
            uniform float4 _liuqv_color2;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
/////// Vectors:
////// Lighting:
////// Emissive:
                float4 _main_var = tex2D(_main,TRANSFORM_TEX(i.uv0, _main));
                float4 _liudong_var = tex2D(_liudong,TRANSFORM_TEX(i.uv0, _liudong));
                float4 _liudong2_var = tex2D(_liudong, TRANSFORM_TEX(i.uv0, _liudong2));
                float4 _mask_var = tex2D(_mask,TRANSFORM_TEX(i.uv0, _mask));
                float3 emissive = _main_var.rgb+((2.0*_liudong_var.rgb*_liuqv_color.rgb + 2.0*_liudong2_var.rgb*_liuqv_color2.rgb)*_mask_var.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
