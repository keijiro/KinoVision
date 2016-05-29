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
Shader "Hidden/Kino/Vision/Motion"
{
    Properties
    {
        _MainTex("", 2D) = ""{}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    sampler2D_half _CameraMotionVectorsTexture;

    half _Opacity;
    half _Amplitude;
    float2 _Scale;

    // Convert a motion vector into RGBA color.
    half4 VectorToColor(float2 mv)
    {
        half phi = atan2(mv.x, mv.y);
        half hue = (phi / UNITY_PI + 1) * 0.5;

        half r = abs(hue * 6 - 3) - 1;
        half g = 2 - abs(hue * 6 - 2);
        half b = 2 - abs(hue * 6 - 4);
        half a = length(mv);

        return saturate(half4(r, g, b, a));
    }

    // Motion vectors imaging shader (fragment only)
    half4 frag_mv_imaging(v2f_img i) : SV_Target
    {
        half4 src = tex2D(_MainTex, i.uv);

        half2 mv = tex2D(_CameraMotionVectorsTexture, i.uv).rg * _Amplitude;
    #if UNITY_UV_STARTS_AT_TOP
        mv.y *= -1;
    #endif

        half4 mc = VectorToColor(mv);

        half3 rgb = src.rgb;
    #if !UNITY_COLORSPACE_GAMMA
        rgb = LinearToGammaSpace(rgb);
    #endif
        rgb = lerp(rgb, mc.rgb, mc.a * _Opacity);
    #if !UNITY_COLORSPACE_GAMMA
        rgb = GammaToLinearSpace(rgb);
    #endif

        return half4(rgb, src.a);
    }

    // Vertex/fragment shader for drawing arrows
    struct v2f_arrows
    {
        float4 vertex : SV_POSITION;
        float2 scoord : TEXCOORD;
        half4 color : COLOR;
    };

    v2f_arrows vert_mv_arrows(appdata_base v)
    {
        // Retrieve the motion vector.
        float4 uv = float4(v.texcoord.xy, 0, 0);
    #if UNITY_UV_STARTS_AT_TOP
        uv.y = 1 - uv.y;
    #endif
        half2 mv = tex2Dlod(_CameraMotionVectorsTexture, uv).rg * _Amplitude;
    #if UNITY_UV_STARTS_AT_TOP
        mv.y *= -1;
    #endif

        // Arrow color
        half4 color = VectorToColor(mv);

        // Make a rotation matrix based on the motion vector.
        float2x2 rot = float2x2(mv.y, mv.x, -mv.x, mv.y);

        // Rotate and scale the body of the arrow.
        float2 pos = mul(rot, v.vertex.zy) * _Scale;

        // Normalized variant of the motion vector and the rotation matrix.
        float2 mv_n = normalize(mv);
        float2x2 rot_n = float2x2(mv_n.y, mv_n.x, -mv_n.x, mv_n.y);

        // Rotate and scale the head of the arrow.
        float2 head = float2(v.vertex.x, -abs(v.vertex.x)) * 0.3;
        head *= saturate(color.a);
        pos += mul(rot_n, head) * _Scale;

        // Offset the arrow position.
        pos += v.texcoord.xy * 2 - 1;

        // Convert to the screen coordinates.
        float2 scoord = (pos + 1) * 0.5 * _ScreenParams.xy;

        // Snap to a pixel-perfect position.
        scoord = round(scoord);

        // Bring back to the normalized screen space.
        pos = (scoord + 0.5) * (_ScreenParams.zw - 1) * 2 - 1;

        // Color tweaks
        color.rgb = GammaToLinearSpace(lerp(color.rgb, 1, 0.5));
        color.a *= _Opacity;

        // Output
        v2f_arrows o;
        o.vertex = float4(pos, 0, 1);
        o.scoord = scoord;
        o.color = saturate(color);
        return o;
    }

    half4 frag_mv_arrows(v2f_arrows i) : SV_Target
    {
        // Pseudo anti-aliasing.
        float aa = length(frac(i.scoord) - 0.5) / 0.707;
        aa *= (aa * (aa * 0.305306011 + 0.682171111) + 0.012522878); // gamma

        half4 c = i.color;
        c.a *= aa;
        return c;
    }

    ENDCG

    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_mv_imaging
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_mv_arrows
            #pragma fragment frag_mv_arrows
            #pragma target 3.0
            ENDCG
        }
    }
}
