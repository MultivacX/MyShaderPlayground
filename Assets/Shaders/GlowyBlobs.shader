// https://www.shadertoy.com/view/Mfj3Rd
Shader "Shader Toy/Glowy Blobs"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Range ("Range", Range(0.1, 10)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
            #pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Range;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            #define FLT_MAX 3.402823466e+38

            // Aspect ratio, for SDFs
            // #define AR float2(iResolution.x/iResolution.y, 1)
            const float2 AR = 1;

            float S(float2 p, float2 r)
            {
                return length((p) * AR) - r;
            }

            // float3 max3(float3 v) { return max(v.x, max(v.y, v.z)); }

            float2 hash23(float3 p3)
            {
                p3 = frac(p3 * float3(.1031, .1030, .0973));
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.xx + p3.yz) * p3.zy);
            }

            // Wrap Around S
            float wrap_around_2_S(float2 uv, float2 p, float r)
            {
                uv -= p;
                return S(uv - round(uv), r);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                static const float3 COLORS[9] =
                {
                    float3(1, 0, 0.5),
                    float3(1, 0.5, 0),
                    float3(0, 1, 0.5),
                    float3(0.5, 1, 0),
                    float3(0.5, 0, 1),
                    float3(0, 0.5, 1),
                    float3(1, 1, 0.5),
                    float3(1, 0.5, 1),
                    float3(0.5, 1, 1)
                };
                // SDF Smooth Union parameter
                const float k = 0.3;
                float SEED = 9.0;

                float2 uv = (i.uv * 2.0 - 1.0) * _Range;

                float sd = FLT_MAX;
                float3 cL = float3(0, 0, 0);

                for (int i = 0; i < 9; i++)
                {
                    // Use the color as a seed for the velocity.
                    float2 v = hash23(COLORS[i] * SEED) * 2. - 1.;
                    float2 pos = float2(0.5, 0.5) + v * _Time[1] * 0.3;
                    float d2 = wrap_around_2_S(uv, pos, 0.05);

                    // Smooth union by IQ
                    float h = clamp(0.5 + 0.5 * (d2 - sd) / k, 0.0, 1.0);
                    sd = lerp(d2, sd, h) - k * h * (1.0 - h);

                    cL = lerp(COLORS[i], cL, h);
                }
                cL *= min(1.0, exp(-sd * 10.));
                cL = pow(cL, 2.2);
                fixed4 col = fixed4(cL, 1.0);
                return col;
            }
            ENDCG
        }
    }
}