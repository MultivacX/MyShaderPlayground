// https://www.shadertoy.com/view/MfSGWG
Shader "Shader Toy/Depth_04 Anti aliased"
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

            float3 palette(float t)
            {
                float3 a = float3(0.746, 0.114, 0.325);
                float3 b = float3(0.362, 0.229, 0.476);
                float3 c = float3(0.735, 1.290, 0.433);
                float3 d = float3(1.431, 1.870, 2.782);

                return a + b * cos(6.28318 * (c * t + d));
            }

            float2 aa[4] = {float2(.31, .18), float2(-.18, .31), float2(-.31, -.18), float2(.18, -.31)};

            fixed4 frag(v2f i) : SV_Target
            {
                float pix = 1.0;
                float3 aacolor = 0;
                float3 abcolor = 0;
                for (int k = 0; k < 4; k++)
                {
                    for (int j = 0; j < 4; j++)
                    {
                        float2 uv = (i.uv * 2.0 - 1.0) * _Range;
                        uv += (aa[j] * pix / 2.) + (aa[k] * pix);
                        float2 uv0 = uv;
                        float3 finalColor = 0.0;

                        for (float i = 0.0; i < 2.0; i++)
                        {
                            uv = uv * 5.0 - 2.0;
                            float d = length(uv) * exp(-length(uv0));
                            float3 col = palette(length(uv0) + i * 0.5 + _Time[1] * 1.0);
                            d = sin(d * 3. - _Time[1]) / 10.0;
                            d = abs(d);
                            d = pow(0.01 / d, 1.0);
                            finalColor += col * d;
                        }
                        aacolor += 0.25 * finalColor;
                    }
                    abcolor += 0.125 * aacolor;
                }

                abcolor = pow(abcolor, 2.2);
                fixed4 col = fixed4(abcolor, 1.0);
                return col;
            }
            ENDCG
        }
    }
}