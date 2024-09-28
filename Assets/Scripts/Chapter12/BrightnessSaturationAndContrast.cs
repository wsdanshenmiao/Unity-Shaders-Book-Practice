using UnityEngine;

public class BrightnessSaturationAndContrast : PostEffectsBase
{
    public Shader BSCShader;
    private Material BSCMaterial;
    public Material Material{
        get{ BSCMaterial = CheckShaderAndCreateMaterial(BSCShader, BSCMaterial); return BSCMaterial; }
    }

    [Range(0, 3)]
    public float Brightness = 1.0f;
    [Range(0, 3)]
    public float Saturation = 1.0f;
    [Range(0, 3)]
    public float Contrast = 1.0f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(Material != null){
            Material.SetFloat("_Brightness", Brightness);
            Material.SetFloat("_Saturation", Saturation);
            Material.SetFloat("_Contrast", Contrast);
            Graphics.Blit(src, dest, Material);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
