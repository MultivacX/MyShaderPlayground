// https://www.shadertoy.com/view/DsBczR
Shader "Shader Toy/Flowing Wires"
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

            #define r(a) float2x2(cos(a + float4(0,33,11,0))) 

            #define s(p) ( q = p,                                    \
                d = length(float2(length(q.xy += .5)-.5, q.z)) - .01,  \
                q.yx = mul(q.yx, r(round((atan2(q.y,q.x)-T) * 3.8) / 3.8 + T)), \
                q.x -= .5,                                           \
                O += (sin(t+T)*.1+.1)*(1.+cos(t+T*.5+float4(0,1,2,0))) \
                     / (.5 + pow(length(q)*50., 1.3))            , d ) // return d

            fixed4 frag(const v2f f) : SV_Target
            {
                // float2 uv = (f.uv * 2.0 - 1.0) * _Range;
                float2 F = f.uv;

                float4 O = 0;
                float3  p = 0, q = 0; float2 R = float2(1, 1);
                float i = 0, t = 0, d = 0, T = _Time[1];

                for (O *= i, F += F - R.xy; i++ < 28.;          // raymarch for 28 iterations
                    
                    p = t * normalize(float3(mul(F, r(t*.1)), R.y)),    // ray position
                    p.zx = mul(p.zx, r(T/4.)), p.zy = mul(p.zy, r(T/3.)), p.x += T, // camera movement
                               
                    t += min(min(s( p = frac(p) - .5 ),        // distance to torus + color (x3)
                                 s( float3(-p.y, p.zx)  )),
                                 s( -p.zxy            ))
                );
                return fixed4(pow(O.xyz, 2.2), 1.0);
            }
            ENDCG
        }
    }
}