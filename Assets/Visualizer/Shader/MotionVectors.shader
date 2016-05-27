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

    // Simple blitter
    half4 frag_blit(v2f_img i) : SV_Target
    {
        return tex2D(_MainTex, i.uv) * (1 - _Opacity);
    }

    // Returns the longer vector.
    half2 VMax(half2 v1, half2 v2)
    {
        return lerp(v1, v2, dot(v1, v1) < dot(v2, v2));
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
        half4 color : COLOR;
    };

    v2f_arrows vert_arrows(appdata_base v)
    {
        // Retrieve the motion vector.
        float2 mv = tex2Dlod(_MainTex, float4(v.texcoord.xy, 0, 0)).rg;

        // Make a rotation matrix based on the motion vector.
        float2x2 rot = float2x2(mv.y, mv.x, -mv.x, mv.y);

        // Rotate and scale the arrow.
        float2 pos = mul(rot, v.vertex.xy) * _Scale.xy * _Scale.z;

        // Offset the arrow position.
        pos += v.texcoord.xy * 2 - 1 + _Scale.xy;

        // Arrow color
        float2 mv2 = abs(mv) * _Scale.z;
        float alpha = saturate(length(mv2));
        half4 col = float4(alpha, mv2, alpha);

        // Output
        v2f_arrows o;
        o.vertex = float4(pos, 0, 1);
        o.color = col;
        return o;
    }

    half4 frag_arrows(v2f_arrows i) : SV_Target
    {
        return i.color;
    }

    ENDCG

    Subshader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_blit
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
