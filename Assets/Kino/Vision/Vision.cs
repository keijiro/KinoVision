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

namespace Kino
{
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("Kino Image Effects/Vision")]
    public partial class Vision : MonoBehaviour
    {
        #region Basic property

        [SerializeField, Range(0, 1)]
        float _sourceOpacity = 1;

        #endregion

        #region Properties for depth

        public enum DepthMethod { BlackWhite, Hue }

        [SerializeField, Range(0, 1)]
        float _depthOpacity = 0;

        [SerializeField]
        DepthMethod _depthMethod;

        [SerializeField]
        float _depthRepeat = 10;

        [SerializeField]
        bool _useGBufferForDepth = false;

        #endregion

        #region Properties for normals

        [SerializeField, Range(0, 1)]
        float _normalsOpacity = 0;

        [SerializeField]
        bool _useGBufferForNormals = false;

        [SerializeField]
        bool _detectInvalidNormals = false;

        #endregion

        #region Properties for motion image

        [SerializeField, Range(0, 1)]
        float _motionImageOpacity = 0;

        [SerializeField]
        float _motionImageAmplitude = 10;

        #endregion

        #region Properties for motion vectors

        [SerializeField, Range(0, 1)]
        float _motionVectorsOpacity = 0;

        [SerializeField, Range(8, 64)]
        int _motionVectorsResolution = 16;

        [SerializeField]
        float _motionVectorsAmplitude = 50;

        #endregion

        #region Private properties and methods

        [SerializeField, HideInInspector]
        Shader _commonShader;
        Material _commonMaterial;

        [SerializeField, HideInInspector]
        Shader _depthShader;
        Material _depthMaterial;

        [SerializeField, HideInInspector]
        Shader _normalsShader;
        Material _normalsMaterial;

        [SerializeField, HideInInspector]
        Shader _motionShader;
        Material _motionMaterial;

        ArrowArray _arrows;

        // Target camera
        Camera TargetCamera {
            get { return GetComponent<Camera>(); }
        }

        // Check if the G-buffer is available.
        bool IsGBufferAvailable {
            get { return TargetCamera.actualRenderingPath == RenderingPath.DeferredShading; }
        }

        // Rebuild arrows if needed.
        void PrepareArrows()
        {
            var row = _motionVectorsResolution;
            var col = row * Screen.width / Screen.height;

            if (_arrows.columnCount != col || _arrows.rowCount != row)
            {
                _arrows.DestroyMesh();
                _arrows.BuildMesh(col, row);
            }
        }

        // Draw arrows in an immediate-mode fashion.
        void DrawArrows(RenderTexture rt)
        {
            PrepareArrows();

            var sy = 1.0f / _motionVectorsResolution;
            var sx = sy * rt.height / rt.width;
            _motionMaterial.SetVector("_Scale", new Vector2(sx, sy));

            _motionMaterial.SetFloat("_Opacity", _motionVectorsOpacity);
            _motionMaterial.SetFloat("_Amplitude", _motionVectorsAmplitude);

            RenderTexture.active = rt;
            _motionMaterial.SetPass(1);
            Graphics.DrawMeshNow(_arrows.mesh, Matrix4x4.identity);
        }

        #endregion

        #region MonoBehaviour functions

        void OnEnable()
        {
            // Initialize the pairs of shaders/materials.
            _commonMaterial = new Material(Shader.Find("Hidden/Kino/Vision/Common"));
            _commonMaterial.hideFlags = HideFlags.DontSave;

            _depthMaterial = new Material(Shader.Find("Hidden/Kino/Vision/Depth"));
            _depthMaterial.hideFlags = HideFlags.DontSave;

            _normalsMaterial = new Material(Shader.Find("Hidden/Kino/Vision/Normals"));
            _normalsMaterial.hideFlags = HideFlags.DontSave;

            _motionMaterial = new Material(Shader.Find("Hidden/Kino/Vision/Motion"));
            _motionMaterial.hideFlags = HideFlags.DontSave;

            // Build the array of arrows.
            _arrows = new ArrowArray();
            PrepareArrows();
        }

        void OnDisable()
        {
            DestroyImmediate(_commonMaterial);
            _commonMaterial = null;

            DestroyImmediate(_depthMaterial);
            _depthMaterial = null;

            DestroyImmediate(_normalsMaterial);
            _normalsMaterial = null;

            DestroyImmediate(_motionMaterial);
            _motionMaterial = null;

            _arrows.DestroyMesh();
            _arrows = null;
        }

        void Update()
        {
            // Update depth texture mode.
            if (_depthOpacity > 0)
                if (!(_useGBufferForDepth && IsGBufferAvailable))
                    TargetCamera.depthTextureMode |= DepthTextureMode.DepthNormals;

            if (_normalsOpacity > 0 || _detectInvalidNormals)
                if (!(_useGBufferForNormals && IsGBufferAvailable))
                    TargetCamera.depthTextureMode |= DepthTextureMode.DepthNormals;

            if (_motionImageOpacity > 0 || _motionVectorsOpacity > 0)
                TargetCamera.depthTextureMode |= DepthTextureMode.Depth | DepthTextureMode.MotionVectors;
        }

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            // Blit the original source image.
            var temp = RenderTexture.GetTemporary(source.width, source.height);
            _commonMaterial.SetFloat("_Opacity", _sourceOpacity);
            Graphics.Blit(source, temp, _commonMaterial, 0);

            // Depth
            if (_depthOpacity > 0)
            {
                var pass = (_useGBufferForDepth && IsGBufferAvailable) ? 2 : 0;
                if (_depthMethod == DepthMethod.Hue) pass++;
                var temp2 = RenderTexture.GetTemporary(source.width, source.height);
                _depthMaterial.SetFloat("_Opacity", _depthOpacity);
                _depthMaterial.SetFloat("_Repeat", _depthRepeat);
                Graphics.Blit(temp, temp2, _depthMaterial, pass);
                RenderTexture.ReleaseTemporary(temp);
                temp = temp2;
            }

            // Normals
            if (_normalsOpacity > 0 || _detectInvalidNormals)
            {
                var pass = (_useGBufferForNormals && IsGBufferAvailable) ? 1 : 0;
                if (pass == 1 && _detectInvalidNormals) pass++;
                var temp2 = RenderTexture.GetTemporary(source.width, source.height);
                _normalsMaterial.SetFloat("_Opacity", _normalsOpacity);
                Graphics.Blit(temp, temp2, _normalsMaterial, pass);
                RenderTexture.ReleaseTemporary(temp);
                temp = temp2;
            }

            // Motion vectors (imaging)
            if (_motionImageOpacity > 0)
            {
                var temp2 = RenderTexture.GetTemporary(source.width, source.height);
                _motionMaterial.SetFloat("_Opacity", _motionImageOpacity);
                _motionMaterial.SetFloat("_Amplitude", _motionImageAmplitude);
                Graphics.Blit(temp, temp2, _motionMaterial, 0);
                RenderTexture.ReleaseTemporary(temp);
                temp = temp2;
            }

            // Motion vectors (arrows)
            if (_motionVectorsOpacity > 0) DrawArrows(temp);

            // Finish
            Graphics.Blit(temp, destination);
            RenderTexture.ReleaseTemporary(temp);
        }

        #endregion
    }
}
