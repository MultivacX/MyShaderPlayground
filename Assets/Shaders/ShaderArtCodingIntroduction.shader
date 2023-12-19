// https://www.shadertoy.com/view/mtyGWy
Shader "Shader Toy/Shader Art Coding Introduction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Range ("Range", Range(0.1, 10)) = 1
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
            float _Range;
            // float _FullScreen;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float3 palette(const float t)
            {
                const float3 a = float3(0.5, 0.5, 0.5);
                const float3 b = float3(0.5, 0.5, 0.5);
                const float3 c = float3(1.0, 1.0, 1.0);
                const float3 d = float3(0.263, 0.416, 0.557);

                return a + b * cos(6.28318 * (c * t + d));
            }

            fixed4 frag(const v2f i) : SV_Target
            {
                // const float w = _ScreenParams.x;
                // const float h = _ScreenParams.y;
                // const float s = _FullScreen > 0 ? h / w : 1.0;
                // [-_Range, _Range]
                // f(uv) = (2 * uv - 1) * _Range
                // float2 uv = (i.uv * 2.0 - 1.0) * _Range * float2(1.0, s);
                float2 uv = (i.uv * 2.0 - 1.0) * _Range;
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

                // final_color = pow(final_color, .4545); // 1.0 / 2.2
                final_color = pow(final_color, 2.2);
                fixed4 col = fixed4(final_color, 1.0);
                return col;
            }
            ENDCG
        }
    }
}