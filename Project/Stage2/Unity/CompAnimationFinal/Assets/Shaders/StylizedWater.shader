Shader "Ethan/StylizedWater"
{
    Properties
    {
        _WaterColor ("Water Color", Color) = (0, 1, 1, 1)
        _MainTex ("Water Texture", 2D) = "white" {}

        _FoamColor ("Foam Color", Color) = (0, 1, 1, 1)
        _FoamTex ("Foam", 2D) = "white" {}

        _NormalTex ("NormalMap", 2D) = "bump" {}
        _BumpSlider ("Bump Amount", Range(0,10)) = 1 // Bump intensity slider

        _ScrollX ("Scroll X", Range(-5,5)) = 1
        _ScrollY ("Scroll Y", Range(-5,5)) = 1
        _Freq ("Wave Frequency", Range(0, 5)) = 3.0
        _Speed ("Wave Speed", Range(0, 10)) = 1.0
        _Amp ("Wave Amplitude", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // Include URP core functionality
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION; // Object space position

                float3 normalOS : NORMAL; // Object space normal

                float2 uv : TEXCOORD0; // UV coordinates for texturing
                
                float4 tangentOS : TANGENT; // Tangent for normal mapping
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Homogeneous clip-space position

                float3 normalWS : TEXCOORD1; // World space normal

                float3 tangentWS : TEXCOORD2; // World space tangent

                float2 uv : TEXCOORD0; // UV coordinates

                float3 bitangentWS : TEXCOORD3; // World space bitangent

                float3 viewDirWS : TEXCOORD4; // World space view direction
            };

            // Declare properties for base color, texture, and wave parameters
            float4 _WaterColor;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;

            float4 _FoamColor;
            TEXTURE2D(_FoamTex);
            SAMPLER(sampler_FoamTex);
            float4 _FoamTex_ST;

            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);
            float4 _NormalTex_ST;

            float _ScrollX;
            float _ScrollY;
            float _Freq;
            float _Speed;
            float _Amp;

            CBUFFER_START(UnityPerMaterial)
                float _BumpSlider; // Bump intensity slider
            CBUFFER_END

            // Vertex Shader with wave animation
            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Time-based animation for water waves
                float wave = sin(_Time.y * _Speed + IN.positionOS.x * _Freq) * _Amp;

                // Adjust the vertex y position for wave effect
                float3 displacedPos = IN.positionOS.xyz;
                displacedPos.y += wave;

                // Transform object space position to homogeneous clip-space position
                OUT.positionHCS = TransformObjectToHClip(displacedPos);

                // Transform object space normal and tangent to world space
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.tangentWS = normalize(TransformObjectToWorldNormal(IN.tangentOS.xyz));
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;

                // Calculate view direction in world space
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);

                // Pass UV coordinates to the fragment shader
                OUT.uv = IN.uv;

                return OUT;
            }

            // Fragment Shader to apply texture and base color tint
            half4 frag(Varyings IN) : SV_Target
            {
                // Apply tiling and offset to each texture's UV coordinates
    float2 scrolledUV = TRANSFORM_TEX(IN.uv, _MainTex) + float2(_ScrollX, _ScrollY) * _Time.y;
    float2 scrolledFoamUV = TRANSFORM_TEX(IN.uv, _FoamTex) + float2(_ScrollX, _ScrollY) * (_Time.y * 0.5);
    float2 normalUV = TRANSFORM_TEX(IN.uv, _NormalTex);

    // Sample textures using the transformed UVs
    half4 water = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, scrolledUV) * _WaterColor;
    half4 foam = SAMPLE_TEXTURE2D(_FoamTex, sampler_FoamTex, scrolledFoamUV) * _FoamColor;
    half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, normalUV));
    normalTS.xy *= _BumpSlider;

    // Transform the normal map from tangent to world space
    half3x3 TBN = half3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);
    half3 normalWS = normalize(mul(normalTS, TBN));

    // Lighting calculations
    Light mainLight = GetMainLight();
    half3 lightDirWS = normalize(mainLight.direction);
    half NdotL = saturate(dot(normalWS, lightDirWS));
    half3 diffuse = water.rgb * NdotL;

    // Blend both textures for the final color
    half4 finalColor = half4(diffuse, 1.0) * 0.5 + (water + foam) * 0.5;
    return finalColor;
            }
            
            ENDHLSL
        }
    }
}