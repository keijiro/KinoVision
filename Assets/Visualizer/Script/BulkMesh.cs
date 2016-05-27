using UnityEngine;
using System.Collections.Generic;

namespace Visualizers
{
    public partial class MotionVectors : MonoBehaviour
    {
        class BulkMesh
        {
            public Mesh mesh { get { return _mesh; } }

            Mesh _mesh;

            public void BuildMesh(int columns, int rows)
            {
                // base shape
                var arrow = new Vector3[6]
                {
                    new Vector3(0, 0, 0),
                    new Vector3(0, 1, 0),
                    new Vector3(0, 1, 0),
                    new Vector3(-0.2f, 0.7f, 0),
                    new Vector3(0, 1, 0),
                    new Vector3(0.2f, 0.7f, 0)
                };

                // make the vertex array
                var vcount = 6 * columns * rows;
                var vertices = new List<Vector3>(vcount);
                var uvs = new List<Vector2>(vcount);

                for (var iy = 0; iy < rows; iy++)
                {
                    for (var ix = 0; ix < columns; ix++)
                    {
                        var uv = new Vector2(
                            (float)ix / columns,
                            (float)iy / rows
                        );

                        for (var i = 0; i < 6; i++)
                        {
                            vertices.Add(arrow[i]);
                            uvs.Add(uv);
                        }
                    }
                }

                // make the index array
                var indices = new int[vcount];

                for (var i = 0; i < vcount; i++)
                    indices[i] = i;

                // initialize the mesh object
                _mesh = new Mesh();
                _mesh.hideFlags = HideFlags.DontSave;

                _mesh.SetVertices(vertices);
                _mesh.SetUVs(0, uvs);
                _mesh.SetIndices(indices, MeshTopology.Lines, 0);

                _mesh.Optimize();
                _mesh.UploadMeshData(true);
            }

            public void DestroyMesh()
            {
                DestroyImmediate(_mesh);
                _mesh = null;
            }
        }
    }
}
