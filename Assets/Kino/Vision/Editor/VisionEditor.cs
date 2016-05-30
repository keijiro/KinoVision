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
using UnityEngine;
using UnityEditor;

namespace Kino
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(Vision))]
    public class VisionEditor : Editor
    {
        SerializedProperty _sourceOpacity;

        SerializedProperty _motionImageOpacity;
        SerializedProperty _motionImageAmplitude;

        SerializedProperty _motionVectorsOpacity;
        SerializedProperty _motionVectorsResolution;
        SerializedProperty _motionVectorsAmplitude;

        static GUIContent _textAmplitude = new GUIContent("Amplitude");
        static GUIContent _textOpacity = new GUIContent("Opacity");
        static GUIContent _textResolution = new GUIContent("Resolution");

        void OnEnable()
        {
            _sourceOpacity = serializedObject.FindProperty("_sourceOpacity");

            _motionImageOpacity = serializedObject.FindProperty("_motionImageOpacity");
            _motionImageAmplitude = serializedObject.FindProperty("_motionImageAmplitude");

            _motionVectorsOpacity = serializedObject.FindProperty("_motionVectorsOpacity");
            _motionVectorsResolution = serializedObject.FindProperty("_motionVectorsResolution");
            _motionVectorsAmplitude = serializedObject.FindProperty("_motionVectorsAmplitude");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.LabelField("Source Image", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(_sourceOpacity, _textOpacity);

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Motion Vectors (overlay)", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(_motionImageOpacity, _textOpacity);
            EditorGUILayout.PropertyField(_motionImageAmplitude, _textAmplitude);

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Motion Vectors (arrows)", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(_motionVectorsOpacity, _textOpacity);
            EditorGUILayout.PropertyField(_motionVectorsResolution, _textResolution);
            EditorGUILayout.PropertyField(_motionVectorsAmplitude, _textAmplitude);

            serializedObject.ApplyModifiedProperties();
        }
    }
}
