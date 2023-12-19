// https://www.shadertoy.com/view/dlKfzG
Shader "Shader Toy/Stars for Stefy"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha", Range(0, 1)) = 1
        // _Range ("Range", Range(0.1, 10)) = 2
        // [MaterialToggle] _FullScreen ( "Full Screen", Float ) = 0
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
            float _Alpha;
            // float _Range;
            // float _FullScreen;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // ---------
            float3 palette(float t)
            {
                const float3 a = float3(0.5, 0.5, 0.5);
                const float3 b = float3(0.5, 0.5, 0.5);
                const float3 c = float3(1.0, 1.0, 1.0);
                const float3 d = float3(0.263, 0.416, 0.557);

                return a + b * cos(6.28318 * (c * t + d));
            }

            float3 tutor(float2 uv)
            {
                const float2 uv0 = uv;
                float3 final_color = float3(0.0, 0.0, 0.0);

                for (float i = 0.0; i < 4.0; i++)
                {
                    uv = frac(uv * 1.5) - 0.5;

                    float d = length(uv) * exp(-length(uv0));

                    const float3 col = palette(length(uv0) + i * .4 + _Time[1] * .4);

                    d = sin(d * 8. + _Time[1]) / 8.;
                    d = abs(d);

                    d = pow(0.01 / d, 1.2);

                    final_color += col * d;
                }
            }

            // ---------

            #define NUM_LAYERS 4.

            float2x2 Rot(float a)
            {
                float s = sin(a), c = cos(a);
                return float2x2(c, -s, s, c);
            }

            float Star(float2 uv, float flare)
            {
                float d = length(uv);
                float m = .05 / d;

                float rays = max(0., 1. - abs(uv.x * uv.y * 1000.));
                m += rays * flare;
                uv = mul(uv, Rot(3.1415 / 4.));
                rays = max(0., 1. - abs(uv.x * uv.y * 1000.));
                m += rays * .3 * flare;

                m *= smoothstep(1., .2, d);
                return m;
            }

            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float3 StarLayer(float2 uv)
            {
                float3 col = 0;

                float2 gv = frac(uv) - .5;
                float2 id = floor(uv);

                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 offs = float2(x, y);

                        float n = Hash21(id + offs); // random between 0 and 1
                        float size = frac(n * 345.32);

                        float star = Star(gv - offs - float2(n, frac(n * 34.)) + .5, smoothstep(.9, 1., size) * .6);

                        float3 color = sin(float3(.2, .3, .9) * frac(n * 2345.2) * 123.2) * .5 + .5;
                        color = color * float3(1, .25, 1. + size) + float3(.2, .2, .1) * 2.;

                        star *= sin(_Time[1] * 3. + n * 6.2831) * .5 + 1.;
                        col += star * size * color;
                    }
                }
                return col;
            }

            float3 stars(float2 uv)
            {
                const float t = _Time[0];
                uv = mul(uv, Rot(t));
                float3 col = 0;

                for (float i = 0.; i < 1.; i += 1. / NUM_LAYERS)
                {
                    float depth = frac(i + t);

                    float scale = lerp(20., .5, depth);
                    float fade = depth * smoothstep(1., .9, depth);
                    col += StarLayer(uv * scale + i * 453.2) * fade;
                }
                // col = pow(col, .4545);
                return col;
            }

            // ---------            
            fixed4 frag(v2f i) : SV_Target
            {
                // const float w = _ScreenParams.x;
                // const float h = _ScreenParams.y;
                // const float s = _FullScreen > 0 ? h / w : 1.0;
                // [-_Range, _Range]
                // f(uv) = (2 * uv - 1) * _Range
                float2 uv = (i.uv * 2.0 - 1.0); // * _Range * float2(1.0, s);
                // float3 final_color = tutor(uv);
                float3 final_color = stars(uv);

                fixed4 col = fixed4(final_color, _Alpha);
                return col;
            }
            ENDCG
        }
    }
}