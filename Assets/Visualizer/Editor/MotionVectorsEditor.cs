using UnityEngine;
using UnityEditor;

namespace Visualizers
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(MotionVectors))]
    public class MotionVectorsEditor : Editor
    {
        SerializedProperty _resolution;
        SerializedProperty _scale;
        SerializedProperty _opacity;

        void OnEnable()
        {
            _resolution = serializedObject.FindProperty("_resolution");
            _scale = serializedObject.FindProperty("_scale");
            _opacity = serializedObject.FindProperty("_opacity");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.PropertyField(_resolution);
            EditorGUILayout.PropertyField(_scale);
            EditorGUILayout.PropertyField(_opacity);

            serializedObject.ApplyModifiedProperties();
        }
    }
}
