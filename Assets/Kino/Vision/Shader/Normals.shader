//
// Kino/Vision - Frame visualization utility
//
// Copyright (C) 2016 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
Shader "Hidden/Kino/Vision/Normals"
{
    Properties
    {
        _MainTex("", 2D) = ""{}
        [Gamma] _Opacity("", Float) = 1
        _Validate("", Float) = 1
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;

    sampler2D _CameraGBufferTexture2;
    sampler2D_float _CameraDepthTexture;
    sampler2D _CameraDepthNormalsTexture;

    half _Opacity;
    half _Validate;

    half4 ProcessFragment(float2 uv, float3 n, float isZero)
    {
        half4 src = tex2D(_MainTex, uv);

        float l = length(n);
        float invalid = max(l < 0.99, l > 1.01) - isZero;

        n = (n + 1) * 0.5;
    #if !UNITY_COLORSPACE_GAMMA
        n = GammaToLinearSpace(n);
    #endif

        return half4(lerp(lerp(src.rgb, n, _Opacity), half3(1, 0, 0), invalid), src.a);
    }

    half4 frag_DepthNormals(v2f_img i) : SV_Target
    {
        float4 cdn = tex2D(_CameraDepthNormalsTexture, i.uv);
        float3 n = DecodeViewNormalStereo(cdn);
        float isZero = (dot(n, 1) == 0);
        return ProcessFragment(i.uv, n, isZero);
    }

    half4 frag_GBuffer(v2f_img i) : SV_Target
    {
        float3 n = tex2D(_CameraGBufferTexture2, i.uv).xyz;
        float isZero = (dot(n, 1) == 0);
        n.z = 1 - n.z;
        n = n * 2 - 1;
        return ProcessFragment(i.uv, n, isZero);
    }

    ENDCG

    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_DepthNormals
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_GBuffer
            #pragma target 3.0
            ENDCG
        }
    }
}
