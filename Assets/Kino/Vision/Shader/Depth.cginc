#include "UnityCG.cginc"

sampler2D _MainTex;
half _Opacity;
half _Repeat;

sampler2D_float _CameraDepthTexture;
sampler2D _CameraDepthNormalsTexture;

float3 Hue(float h)
{
    float r = abs(h * 6 - 3) - 1;
    float g = 2 - abs(h * 6 - 2);
    float b = 2 - abs(h * 6 - 4);
    return saturate(float3(r, g, b));
}

half4 frag_depth(v2f_img i) : SV_Target
{
    half4 src = tex2D(_MainTex, i.uv);

#ifdef USE_CAMERA_DEPTH
    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
    depth = Linear01Depth(depth);
    depth = 1 - depth;
#else // USE_CAMERA_DEPTH_NORMALS
    float4 cdn = tex2D(_CameraDepthNormalsTexture, i.uv);
    float depth = DecodeFloatRG(cdn.zw) * _ProjectionParams.x;
#endif

#ifdef VISUALIZE_BLACK_WHITE
    half3 rgb = frac(depth * _Repeat);
#else // VISUALIZE_HUE
    half3 rgb = Hue(frac(depth * _Repeat));
#endif

#if !UNITY_COLORSPACE_GAMMA
    rgb = GammaToLinearSpace(rgb);
#endif

    rgb = lerp(src.rgb, rgb, _Opacity);

    return half4(rgb, src.a);
}
