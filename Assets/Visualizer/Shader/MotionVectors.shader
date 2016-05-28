Shader "Hidden/Visualizers/MotionVectors"
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
    float3 _Scale; // x, y, magnitude

    // Gamma decoding function
    float Gamma(float c)
    {
        return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
    }

    // RGB color from a hue value
    half3 HueToRGB(half h)
    {
        half r = abs(h * 6 - 3) - 1;
        half g = 2 - abs(h * 6 - 2);
        half b = 2 - abs(h * 6 - 4);
        return saturate(half3(r, g, b));
    }

    // Convert a motion vector into RGBA color.
    // RGB: color, Alpha: magnitude
    half4 VectorToColor(float2 mv)
    {
        half phi = atan2(mv.x, mv.y);
        half hue = (phi / UNITY_PI + 1) * 0.5;
        half amp = saturate(length(mv * _Scale.z));
        return half4(HueToRGB(hue), amp);
    }

    // Returns the longer vector.
    half2 VMax(half2 v1, half2 v2)
    {
        return lerp(v1, v2, dot(v1, v1) < dot(v2, v2));
    }

    // Visualization with color
    half4 frag_color(v2f_img i) : SV_Target
    {
        half4 src = tex2D(_MainTex, i.uv);
        half2 mv = tex2D(_CameraMotionVectorsTexture, i.uv).rg;
        half4 mc = VectorToColor(mv);

        half3 rgb = src.rgb;
    #if !UNITY_COLORSPACE_GAMMA
        rgb = LinearToGammaSpace(rgb);
    #endif
        rgb = lerp(rgb * _Opacity, mc.rgb, mc.a);
    #if !UNITY_COLORSPACE_GAMMA
        rgb = GammaToLinearSpace(rgb);
    #endif

        return half4(rgb, src.a);
    }

    // Fragment shader for motion vector retrieval
    half4 frag_mv_retrieval(v2f_img i) : SV_Target
    {
        float4 duv = _MainTex_TexelSize.xyxy * float4(0.5, 0.5, -0.5, -0.5);
        half2 mv0 = tex2D(_CameraMotionVectorsTexture, i.uv + duv.xy).rg;
        half2 mv1 = tex2D(_CameraMotionVectorsTexture, i.uv + duv.xw).rg;
        half2 mv2 = tex2D(_CameraMotionVectorsTexture, i.uv + duv.zy).rg;
        half2 mv3 = tex2D(_CameraMotionVectorsTexture, i.uv + duv.zw).rg;
        return VMax(VMax(VMax(mv0, mv1), mv2), mv3).xyxy;
    }

    // Fragment shader for shrinking motion map
    half4 frag_mv_shrink(v2f_img i) : SV_Target
    {
        float4 duv = _MainTex_TexelSize.xyxy * float4(0.5, 0.5, -0.5, -0.5);
        half2 mv0 = tex2D(_MainTex, i.uv - duv.xy).rg;
        half2 mv1 = tex2D(_MainTex, i.uv - duv.zw).rg;
        half2 mv2 = tex2D(_MainTex, i.uv + duv.zy).rg;
        half2 mv3 = tex2D(_MainTex, i.uv + duv.zw).rg;
        return VMax(VMax(VMax(mv0, mv1), mv2), mv3).xyxy;
    }

    // Vertex/fragment shader for drawing arrows
    struct v2f_arrows
    {
        float4 vertex : SV_POSITION;
        float2 scoord : TEXCOORD;
        half4 color : COLOR;
    };

    v2f_arrows vert_arrows(appdata_base v)
    {
        // Retrieve the motion vector.
        float2 mv = tex2Dlod(_MainTex, float4(v.texcoord.xy, 0, 0)).rg;

        // Arrow color
        half4 color = VectorToColor(mv);

        // Make a rotation matrix based on the motion vector.
        float2x2 rot = float2x2(mv.y, mv.x, -mv.x, mv.y);

        // Rotate and scale the body of the arrow.
        float2 pos = mul(rot, v.vertex.zy) * _Scale.xy * _Scale.z * 5;

        // Normalized variant of the motion vector and the rotation matrix.
        float2 mv_n = normalize(mv);
        float2x2 rot_n = float2x2(mv_n.y, mv_n.x, -mv_n.x, mv_n.y);

        // Rotate and scale the head of the arrow.
        float2 head = float2(v.vertex.x, -abs(v.vertex.x)) * 0.3 * saturate(color.a * 5);
        pos += mul(rot_n, head) * _Scale.xy;

        // Offset the arrow position.
        pos += v.texcoord.xy * 2 - 1 + _Scale.xy;

        // Convert to the screen coordinates.
        float2 scoord = (pos + 1) * 0.5 * _ScreenParams.xy;

        // Snap to a pixel-perfect position.
        scoord = round(scoord);

        // Bring back to the normalized screen space.
        pos = (scoord + 0.5) * (_ScreenParams.zw - 1) * 2 - 1;


        color.rgb = GammaToLinearSpace(lerp(color.rgb, 1, 0.5));

        // Output
        v2f_arrows o;
        o.vertex = float4(pos, 0, 1);
        o.scoord = scoord;
        o.color = color;
        return o;
    }


    half4 frag_arrows(v2f_arrows i) : SV_Target
    {
        half4 c = i.color;
        c.a *= Gamma(length(frac(i.scoord) - 0.5) / 0.71);
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
            #pragma fragment frag_color
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_mv_retrieval
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_mv_shrink
            #pragma target 3.0
            ENDCG
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_arrows
            #pragma fragment frag_arrows
            #pragma target 3.0
            ENDCG
        }
    }
}
