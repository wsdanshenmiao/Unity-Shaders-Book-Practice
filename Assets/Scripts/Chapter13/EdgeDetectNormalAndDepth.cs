using UnityEngine;

public class EdgeDetectNormalAndDepth : PostEffectsBase
{
    public Shader degeDetectShader;
    private Material m_Material;
    public Material edgeDetectMaterial{
        get { m_Material = CheckShaderAndCreateMaterial(degeDetectShader, m_Material); return m_Material; }
    }

    [Range(0,1)]
    public float edgeOnly = 0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1f;
    public float sensitivityDepth = 1f;
    public float sensitivityNormal = 1f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    // 任何具有ImageEffectOpaque属性的图像效果都将在不透明几何形状之后但在透明几何形状之前渲染
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(edgeDetectMaterial != null){
            edgeDetectMaterial.SetFloat("_EdgeOnly", edgeOnly);
            edgeDetectMaterial.SetColor("_EdgeColor", edgeColor);
            edgeDetectMaterial.SetColor("_BackgroundColor", backgroundColor);
            edgeDetectMaterial.SetFloat("_SampleDistance", sampleDistance);
            edgeDetectMaterial.SetVector("_Sensitivity", new Vector4(sensitivityDepth, sensitivityNormal, 0, 0));
            Graphics.Blit(src, dest, edgeDetectMaterial);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
