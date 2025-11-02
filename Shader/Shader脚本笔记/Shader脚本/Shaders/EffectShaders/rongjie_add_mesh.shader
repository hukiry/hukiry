// Shader created with Shader Forge v1.27 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.27;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33503,y:32789,varname:node_3138,prsc:2|emission-1794-OUT,alpha-6906-OUT;n:type:ShaderForge.SFN_Tex2d,id:7563,x:32166,y:32605,ptovrint:False,ptlb:1_texture,ptin:_1_texture,varname:node_7563,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:9841,x:31694,y:32928,ptovrint:False,ptlb:2_texture,ptin:_2_texture,varname:node_9841,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_If,id:847,x:32088,y:32769,varname:node_847,prsc:2|A-4039-OUT,B-9841-R,GT-8988-OUT,EQ-7236-OUT,LT-7236-OUT;n:type:ShaderForge.SFN_If,id:4310,x:32134,y:32974,varname:node_4310,prsc:2|A-8536-OUT,B-9841-R,GT-8988-OUT,EQ-7236-OUT,LT-7236-OUT;n:type:ShaderForge.SFN_Vector1,id:7236,x:31829,y:33192,varname:node_7236,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:8988,x:31829,y:33271,varname:node_8988,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:2341,x:31713,y:32691,varname:node_2341,prsc:2,v1:0.05;n:type:ShaderForge.SFN_Add,id:4039,x:31888,y:32713,varname:node_4039,prsc:2|A-2341-OUT,B-8536-OUT;n:type:ShaderForge.SFN_Subtract,id:9556,x:32307,y:32930,varname:node_9556,prsc:2|A-847-OUT,B-4310-OUT;n:type:ShaderForge.SFN_Color,id:5,x:32181,y:33278,ptovrint:False,ptlb:5_color,ptin:_5_color,varname:node_5,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:204,x:32643,y:32976,varname:node_204,prsc:2|A-9556-OUT,B-5-RGB,C-5-A;n:type:ShaderForge.SFN_Add,id:1794,x:32948,y:32768,varname:node_1794,prsc:2|A-537-OUT,B-204-OUT;n:type:ShaderForge.SFN_Multiply,id:537,x:32626,y:32660,varname:node_537,prsc:2|A-123-RGB,B-7563-RGB,C-6827-OUT;n:type:ShaderForge.SFN_Multiply,id:6906,x:32814,y:33273,varname:node_6906,prsc:2|A-7563-A,B-847-OUT,C-123-A;n:type:ShaderForge.SFN_Slider,id:8536,x:31267,y:32770,ptovrint:False,ptlb:3_rongjiedu,ptin:_3_rongjiedu,varname:node_8536,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Color,id:123,x:32242,y:32377,ptovrint:False,ptlb:4_color_texture,ptin:_4_color_texture,varname:node_123,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Slider,id:6827,x:32831,y:32928,ptovrint:False,ptlb:6_light,ptin:_6_light,varname:node_6827,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:3;proporder:7563-9841-5-8536-123-6827;pass:END;sub:END;*/

Shader "Shader Forge/rongjie_add_mesh" {
    Properties {
        _1_texture ("1_texture", 2D) = "white" {}
        _2_texture ("2_texture", 2D) = "white" {}
        _5_color ("5_color", Color) = (1,1,1,1)
        _3_rongjiedu ("3_rongjiedu", Range(0, 1)) = 1
        _4_color_texture ("4_color_texture", Color) = (1,1,1,1)
        _6_light ("6_light", Range(0, 3)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers gles3 d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _1_texture; uniform float4 _1_texture_ST;
            uniform sampler2D _2_texture; uniform float4 _2_texture_ST;
            uniform float4 _5_color;
            uniform float _3_rongjiedu;
            uniform float4 _4_color_texture;
            uniform float _6_light;
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
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 _1_texture_var = tex2D(_1_texture,TRANSFORM_TEX(i.uv0, _1_texture));
                float4 _2_texture_var = tex2D(_2_texture,TRANSFORM_TEX(i.uv0, _2_texture));
                float node_847_if_leA = step((0.05+_3_rongjiedu),_2_texture_var.r);
                float node_847_if_leB = step(_2_texture_var.r,(0.05+_3_rongjiedu));
                float node_7236 = 0.0;
                float node_8988 = 1.0;
                float node_847 = lerp((node_847_if_leA*node_7236)+(node_847_if_leB*node_8988),node_7236,node_847_if_leA*node_847_if_leB);
                float node_4310_if_leA = step(_3_rongjiedu,_2_texture_var.r);
                float node_4310_if_leB = step(_2_texture_var.r,_3_rongjiedu);
                float3 emissive = ((_4_color_texture.rgb*_1_texture_var.rgb*_6_light)+((node_847-lerp((node_4310_if_leA*node_7236)+(node_4310_if_leB*node_8988),node_7236,node_4310_if_leA*node_4310_if_leB))*_5_color.rgb*_5_color.a));
                float3 finalColor = emissive;
                return fixed4(finalColor,(_1_texture_var.a*node_847*_4_color_texture.a));
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
