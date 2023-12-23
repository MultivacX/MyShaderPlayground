// https://www.shadertoy.com/view/4fX3D7
Shader "Shader Toy/Orb Audio Lines"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Range ("Range", Range(0.1, 10)) = 1.6
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
            float _Range;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 main(v2f f);

            fixed4 frag(v2f i) : SV_Target
            {
                return main(i);
            }

            // --------

            const float TAU = 6.2831;

            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            float2 rand(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                return 2.0 * frac(sin(p) * 43758.5453123) - 1.0;
            }

            float noise(float2 p)
            {
                float2 i = floor(p + (p.x + p.y) * 0.366025404);
                float2 a = p - i + (i.x + i.y) * 0.211324865;
                float m = step(a.y, a.x);
                float2 o = float2(m, 1.0 - m);
                float2 b = a - o + 0.211324865;
                float2 c = a - 1.0 + 2.0 * 0.211324865;
                float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
                float3 n = h * h * h * h * float3(dot(a, rand(i + 0.0)), dot(b, rand(i + o)), dot(c, rand(i + 1.0)));
                return dot(n, 70) * .5 + .5;
            }

            float2 rot2D(float2 v, float a)
            {
                float s = sin(a);
                float c = cos(a);
                float2x2 m = float2x2(c, s, -s, c);
                return mul(v, m);
            }

            float luma(float3 color)
            {
                return dot(color, float3(0.299, 0.587, 0.114));
            }

            float4 orb(float2 uv, float t, float min_res)
            {
                float l = dot(uv, uv);
                l *= l * l * l;
                float3 n = normalize(float3(uv, sqrt(abs(1.0 - l))));
                float f = 48.0 / min_res;
                float mask = smoothstep(1.0, 1.0 - f, l);
                float alpha = pow(l, 0.2) * mask;
                float4 col = float4(lerp(float3(0.1, 0.0, 0.5), float3(0.4, 0, 0.5),
                                         min(1.0, dot(n, float3(.5, .5, -.1)) + l)), alpha);
                col.rgb += smoothstep(0., 1., noise(rot2D(n.xy, -t * 0.5) / (1.0 + n.z * n.z * n.z) + t)) * float3(
                    .4, .2, .7);
                col.rgb += smoothstep(.2, .9, noise(rot2D(n.xy, t) * 2. / (1.0 + n.z * n.z * n.z) - t)) *
                    smoothstep(0.2, 0.0, l) * float3(.2, .1, .5);
                float fresnel = mask * (luma(col.rgb) + 0.5) * pow(l, 4.0);
                col.rgb += fresnel;
                col.a += col.a * fresnel;
                float s = smoothstep(1., -1.0, noise(float2(-t, -t) + n.z * 3. + noise(noise(n.xy) * 4. +
                                         normalize(rot2D(n.xy, t)) * (0.9 + length(n.xy) * 1.5) * 4. + t) * .2));
                col = float4(lerp(col.rgb - float3(0.2, .3, .6) * s, col.rgb, s), col.a / (1.0 + 1. * s));
                float d = 1.0 / (0.1 + pow(length(uv) - 1.0, 2.));
                col.a += (1.0 - mask) * d * 0.1;
                return col;
            }

            float4 lines(float2 uv, float t)
            {
                t *= 0.6;
                float4 col = 0;
                float2 nv = normalize(uv);
                float d = 1.0 + noise(nv + t) * .2;

                float mask = smoothstep(0.05, 0.0, distance(nv * d, uv));
                col.rgb = lerp(col.rgb, float3(0.3, 1, 0.5) + smoothstep(0.96, 1.05, mask), mask);
                col.a += mask;

                d = 1.0 + noise(nv + t + 85.161) * .2;
                mask = smoothstep(0.05, 0.0, distance(nv * d, uv));
                col.rgb = lerp(col.rgb, float3(0.2, 0.7, 1) + smoothstep(0.96, 1.05, mask), mask);
                col.a += mask;

                d = 1.0 + noise(nv + t - 85.161) * .2;
                mask = smoothstep(0.05, 0.0, distance(nv * d, uv));
                col.rgb = lerp(col.rgb, float3(1, 0.2, 0.4) + smoothstep(0.94, 1.05, mask), mask);
                col.a += mask;

                return col;
            }

            fixed4 main(v2f f)
            {
                // const float w = _ScreenParams.x;
                // const float h = _ScreenParams.y;
                // const float s = _FullScreen > 0 ? h / w : 1.0;
                // [-_Range, _Range]
                // f(uv) = (2 * uv - 1) * _Range
                float2 uv = (f.uv * 2.0 - 1.0) * _Range; // * float2(1.0, s);

                fixed4 fragColor = 0;

                float t = _Time[1] * 0.5;
                fragColor.a = 0.0;

                float3 col = 0;
                float4 orb4 = orb(uv, t, 1.0);
                col.rgb += orb4.rgb * orb4.a;
                fragColor.a += orb4.a;

                float4 li = lines(uv, t);
                col.rgb = orb4.rgb * orb4.a;
                col.rgb = lerp(col.rgb, li.rgb, li.a);
                fragColor.a += li.a;

                fragColor.rgb = col * fragColor.a;
                fragColor = pow(fragColor, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}