using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectionShader;
    private Material m_Material = null;
    public Material Material{
        get { m_Material = CheckShaderAndCreateMaterial(edgeDetectionShader, m_Material); return m_Material; }
    }

    [Range(0 ,1)]
    public float edgeOnly = 1;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Material != null){
            Material.SetFloat("_EdgeOnly", edgeOnly);
            Material.SetColor("_EdgeColor", edgeColor);
            Material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(src, dest, Material);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
