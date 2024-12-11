Shader "Ethan/FoliageSway"
{
    Properties
    {
        [Header(Foliage Sway Properties)]
        _MainTex("Main Texture", 2D) = "black" {}
        _FoliageTint("Tint", Color) = (1,1,1,1)
        _AlphaCutoff("Alpha Clipping", Range(0, 1)) = 0.08
        _SwaySpeedX("Wind Sway Speed X", Range(0, 1)) = 0.3 
        _SwaySpeedY("Wind Sway Speed Y", Range(0, 1)) = 0.3 
        _SwaySpeedZ("Wind Sway Speed Z", Range(0, 1)) = 0.3 
        _Amp("Wave Amplitude", Range(0, 1)) = 0.1
        _Freq("Wave Frequency", Range(0, 5)) = 3.0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include URP core functionality
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Foliage Sway Properties
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _FoliageTint;
            float _AlphaCutoff;
            float _SwaySpeedX, _SwaySpeedY, _SwaySpeedZ;
            float _Amp;
            float _Freq;

            struct Appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Appdata IN)
            {
                Varyings OUT;

                // Apply sway effect to vertex positions
                float3 displacedPos = IN.positionOS.xyz;

                // Sway along X, Y, and Z using time-based sine waves
                displacedPos.x += sin(_Time.y * _SwaySpeedX + IN.positionOS.y * _Freq) * _Amp;
                displacedPos.y += sin(_Time.y * _SwaySpeedY + IN.positionOS.z * _Freq) * _Amp;
                displacedPos.z += sin(_Time.y * _SwaySpeedZ + IN.positionOS.x * _Freq) * _Amp;

                // Transform displaced positions to clip space
                OUT.positionHCS = TransformObjectToHClip(displacedPos);
                OUT.uv = IN.uv;

                return OUT;
            }

            float4 frag(Varyings IN) : SV_TARGET
            {
                // Sample the main texture and apply the tint
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _FoliageTint;

                // Apply alpha clipping
                clip(color.a - _AlphaCutoff);

                return color;
            }

            ENDHLSL
        }
    }
}