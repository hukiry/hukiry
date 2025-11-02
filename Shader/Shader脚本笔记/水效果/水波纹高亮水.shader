// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MagicFire/Water"
{
    Properties
    {
        _ColorShallow("Color (Shallow)", Color) = (0,0.2941177,0.2078431,0)
        _ColorDeep("Color (Deep)", Color) = (0,0.1803922,0.1254902,0)
        _Glossiness("Glossiness", Range( 0 , 1)) = 0.75
        [HideInInspector]_NormalMap("Normal Map", 2D) = "bump" {}
        _NormalBlendStrength("Normal Blend Strength", Range( 0 , 1)) = 0
        _NormalMap1Strength("Normal Map 1 Strength", Range( 0 , 1)) = 0
        _NormalMap2Strength("Normal Map 2 Strength", Range( 0 , 1)) = 0
        _UVScale("UV Scale", Float) = 1
        _UV1Tiling("UV 1 Tiling", Float) = 0
        _UV2Tiling("UV 2 Tiling", Float) = 0
        _UV1Animator("UV 1 Animator", Vector) = (0,0,0,0)
        _UV2Animator("UV 2 Animator", Vector) = (0,0,0,0)
        [HideInInspector] __dirty( "", Int ) = 1
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
        Cull Off
        CGPROGRAM
        #include "UnityStandardUtils.cginc"
        #include "UnityShaderVariables.cginc"
        #pragma target 3.0
        #pragma surface surf Standard keepalpha noshadow 
        struct Input
        {
            float3 worldPos;
            INTERNAL_DATA
        };

        uniform sampler2D _NormalMap;
        uniform float _NormalMap1Strength;
        uniform float2 _UV1Animator;
        uniform float _UVScale;
        uniform float _UV1Tiling;
        uniform float _NormalMap2Strength;
        uniform float2 _UV2Animator;
        uniform float _UV2Tiling;
        uniform float _NormalBlendStrength;
        uniform float4 _ColorDeep;
        uniform float4 _ColorShallow;
        uniform float _Glossiness;

        void surf( Input i , inout SurfaceOutputStandard o )
        {
            float3 ase_worldPos = i.worldPos;
            float2 appendResult19 = (float2(ase_worldPos.x , ase_worldPos.z));
            float2 _worldUV22 = ( appendResult19 / _UVScale );
            float2 panner29 = ( _Time.x * _UV1Animator + ( _worldUV22 * _UV1Tiling ));
            float2 _UV141 = panner29;
            float2 panner30 = ( _Time.x * _UV2Animator + ( _worldUV22 * _UV2Tiling ));
            float2 _UV242 = panner30;
            float3 lerpResult4 = lerp( UnpackScaleNormal( tex2D( _NormalMap, _UV141 ), _NormalMap1Strength ) , UnpackScaleNormal( tex2D( _NormalMap, _UV242 ), _NormalMap2Strength ) , _NormalBlendStrength);
            float3 _normalMap12 = lerpResult4;
            o.Normal = _normalMap12;
            float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
            float fresnelNdotV14 = dot( _normalMap12, ase_worldViewDir );
            float fresnelNode14 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV14, 1.336 ) );
            float4 lerpResult11 = lerp( _ColorDeep , _ColorShallow , fresnelNode14);
            float4 _color16 = lerpResult11;
            o.Albedo = _color16.rgb;
            o.Smoothness = _Glossiness;
            o.Alpha = 1;
        }

        ENDCG
    }
    CustomEditor "ASEMaterialInspector"
}