Shader "Custom/Wrong Normal"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;

        struct Input {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float phase = IN.uv_MainTex.x * 100;
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            o.Normal = float3(0, 0, 1 + sin(phase) * 0.2);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
