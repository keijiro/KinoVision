using UnityEngine;

namespace Visualizers
{
    [RequireComponent(typeof(Camera))]
    public partial class MotionVectors : MonoBehaviour
    {
        #region Editable properties

        [SerializeField, Range(8, 64)]
        int _resolution = 10;

        [SerializeField]
        float _scale = 3;

        [SerializeField, Range(0, 1)]
        float _opacity = 0;

        #endregion

        #region Private properties and methods

        [SerializeField, HideInInspector]
        Shader _shader;

        Material _material;
        BulkMesh _arrows;

        void PrepareArrows()
        {
            var columns = _resolution * Screen.width / Screen.height;
            if (_arrows.columnCount != columns || _arrows.rowCount != _resolution)
            {
                _arrows.DestroyMesh();
                _arrows.BuildMesh(columns, _resolution);
            }
        }

        #endregion

        #region MonoBehaviour functions

        void OnEnable()
        {
            // Initialize the shader/material.
            var shader = Shader.Find("Hidden/Visualizers/MotionVectors");
            _material = new Material(shader);
            _material.hideFlags = HideFlags.DontSave;

            // Requires motion vectors.
            GetComponent<Camera>().depthTextureMode |=
                DepthTextureMode.Depth | DepthTextureMode.MotionVectors;

            // Build the mesh of arrows.
            _arrows = new BulkMesh();
            PrepareArrows();
        }

        void OnDisable()
        {
            DestroyImmediate(_material);
            _material = null;

            _arrows.DestroyMesh();
            _arrows = null;
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            const RenderTextureFormat rghalf = RenderTextureFormat.RGHalf;

            PrepareArrows();

            // Retrieve the motion vectors and shrink it.
            var mv_w = source.width / 2;
            var mv_h = source.height / 2;

            RenderTexture mv = RenderTexture.GetTemporary(mv_w, mv_h, 0, rghalf);
            Graphics.Blit(source, mv, _material, 1);

            // Shrink repeatedly until the size matches to the resolution.
            while (mv_h > _resolution * 2)
            {
                mv_w /= 2;
                mv_h /= 2;

                var mv_next = RenderTexture.GetTemporary(mv_w, mv_h, 0, rghalf);
                Graphics.Blit(mv, mv_next, _material, 2);

                if (mv != null) RenderTexture.ReleaseTemporary(mv);
                mv = mv_next;
            }

            // Blit the original source image.
            _material.SetFloat("_Opacity", _opacity);
            Graphics.Blit(source, destination, _material, 0);

            // Set the scale parameter.
            var sy = 1.0f / _resolution;
            var sx = sy * Screen.height / Screen.width;
            _material.SetVector("_Scale", new Vector3(sx, sy, _scale));

            // Draw the arrows.
            _material.SetTexture("_MainTex", mv);
            _material.SetPass(3);
            Graphics.DrawMeshNow(_arrows.mesh, Matrix4x4.identity);

            // Cleaning up.
            RenderTexture.ReleaseTemporary(mv);
        }

        #endregion
    }
}
