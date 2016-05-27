using UnityEngine;
using UnityEditor;

public class PackageTool
{
    [MenuItem("Package/Update Package")]
    static void UpdatePackage()
    {
        AssetDatabase.ExportPackage("Assets/Visualizer", "MotionVectorsVisualizer.unitypackage", ExportPackageOptions.Recurse);
    }
}
