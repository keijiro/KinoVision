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
    [CustomEditor(typeof(Vision))]
    public class VisionEditor : Editor
    {
        // Common
        SerializedProperty _sourceOpacity;
        SerializedProperty _useDepthNormals;

        // Depth
        SerializedProperty _enableDepth;
        SerializedProperty _depthOpacity;
        SerializedProperty _depthRepeat;

        static GUIContent _textDepth = new GUIContent("Depth");
        static GUIContent _textOpacity = new GUIContent("Opacity");
        static GUIContent _textRepeat = new GUIContent("Repeat");

        // Normals
        SerializedProperty _enableNormals;
        SerializedProperty _normalsOpacity;
        SerializedProperty _detectInvalidNormals;

        static GUIContent _textNormals = new GUIContent("Normals");
        static GUIContent _textCheckValidity = new GUIContent("Check Validity");

        // Motion (overlay)
        SerializedProperty _enableMotionOverlay;
        SerializedProperty _motionOverlayOpacity;
        SerializedProperty _motionOverlayAmplitude;

        static GUIContent _textMotionOverlay = new GUIContent("Motion (overlay)");
        static GUIContent _textAmplitude = new GUIContent("Amplitude");

        // Motion (vectors)
        SerializedProperty _enableMotionVectors;
        SerializedProperty _motionVectorsOpacity;
        SerializedProperty _motionVectorsResolution;
        SerializedProperty _motionVectorsAmplitude;

        static GUIContent _textMotionVectors = new GUIContent("Motion (vectors)");
        static GUIContent _textResolution = new GUIContent("Resolution");

        void OnEnable()
        {
            // Common
            _sourceOpacity = serializedObject.FindProperty("_sourceOpacity");
            _useDepthNormals = serializedObject.FindProperty("_useDepthNormals");

            // Depth
            _enableDepth = serializedObject.FindProperty("_enableDepth");
            _depthOpacity = serializedObject.FindProperty("_depthOpacity");
            _depthRepeat = serializedObject.FindProperty("_depthRepeat");

            // Normals
            _enableNormals = serializedObject.FindProperty("_enableNormals");
            _normalsOpacity = serializedObject.FindProperty("_normalsOpacity");
            _detectInvalidNormals = serializedObject.FindProperty("_detectInvalidNormals");

            // Motion (overlay)
            _enableMotionOverlay = serializedObject.FindProperty("_enableMotionOverlay");
            _motionOverlayOpacity = serializedObject.FindProperty("_motionOverlayOpacity");
            _motionOverlayAmplitude = serializedObject.FindProperty("_motionOverlayAmplitude");

            // Motion (vectors)
            _enableMotionVectors = serializedObject.FindProperty("_enableMotionVectors");
            _motionVectorsOpacity = serializedObject.FindProperty("_motionVectorsOpacity");
            _motionVectorsResolution = serializedObject.FindProperty("_motionVectorsResolution");
            _motionVectorsAmplitude = serializedObject.FindProperty("_motionVectorsAmplitude");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            // Common
            EditorGUILayout.PropertyField(_sourceOpacity);
            EditorGUILayout.PropertyField(_useDepthNormals);

            if (_enableDepth.boolValue) EditorGUILayout.Space();

            // Depth
            EditorGUILayout.PropertyField(_enableDepth, _textDepth);
            if (_enableDepth.boolValue)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_depthOpacity, _textOpacity);
                EditorGUILayout.PropertyField(_depthRepeat, _textRepeat);
                EditorGUI.indentLevel--;
            }

            if (_enableDepth.boolValue || _enableNormals.boolValue) EditorGUILayout.Space();

            // Normals
            EditorGUILayout.PropertyField(_enableNormals, _textNormals);
            if (_enableNormals.boolValue)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_normalsOpacity, _textOpacity);
                EditorGUILayout.PropertyField(_detectInvalidNormals, _textCheckValidity);
                EditorGUI.indentLevel--;
            }

            if (_enableNormals.boolValue || _enableMotionOverlay.boolValue) EditorGUILayout.Space();

            // Motion (overlay)
            EditorGUILayout.PropertyField(_enableMotionOverlay, _textMotionOverlay);
            if (_enableMotionOverlay.boolValue)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_motionOverlayOpacity, _textOpacity);
                EditorGUILayout.PropertyField(_motionOverlayAmplitude, _textAmplitude);
                EditorGUI.indentLevel--;
            }

            if (_enableMotionOverlay.boolValue || _enableMotionVectors.boolValue) EditorGUILayout.Space();

            // Motion (vectors)
            EditorGUILayout.PropertyField(_enableMotionVectors, _textMotionVectors);
            if (_enableMotionVectors.boolValue)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_motionVectorsOpacity, _textOpacity);
                EditorGUILayout.PropertyField(_motionVectorsResolution, _textResolution);
                EditorGUILayout.PropertyField(_motionVectorsAmplitude, _textAmplitude);
                EditorGUI.indentLevel--;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}
