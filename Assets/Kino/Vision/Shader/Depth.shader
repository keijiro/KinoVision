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
Shader "Hidden/Kino/Vision/Depth"
{
    Properties
    {
        _MainTex("", 2D) = ""{}
        [Gamma] _Opacity("", Float) = 1
    }
    Subshader
    {
        // camera depth
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #define USE_CAMERA_DEPTH
            #include "Depth.cginc"
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #pragma vertex vert_img
            #pragma fragment frag_depth
            #pragma target 3.0
            ENDCG
        }
        // camera depth normals
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #define USE_CAMERA_DEPTH_NORMALS
            #include "Depth.cginc"
            #pragma multi_compile _ UNITY_COLORSPACE_GAMMA
            #pragma vertex vert_img
            #pragma fragment frag_depth
            #pragma target 3.0
            ENDCG
        }
    }
}
