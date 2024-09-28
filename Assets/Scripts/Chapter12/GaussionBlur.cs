using System;
using UnityEngine;
using UnityEngine.UI;

public class GaussionBlur : PostEffectsBase
{
    public Shader GaussionBlurShader;
    private Material m_Material = null;
    
    public Material Material{
        get { m_Material = CheckShaderAndCreateMaterial(GaussionBlurShader, m_Material); return m_Material; }
    }

    // 模糊迭代次数
    [Range(0, 4)]
    public int interator = 1;
    // 模糊范围
    [Range(0.2f, 3)]
    public float blurSpread = 0.6f;
    // 纹理的缩小比例
    [Range(1, 5)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Material != null) {
            // 使纹理变小，减少采样
            int width = src.width / downSample;
            int height = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src, buffer0);

            for (int i = 0; i < interator; ++i) {
                Material.SetFloat("_BlurSize", 1 + i * blurSpread);

                // 进行水平模糊,输出模糊结果到buffer1
                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, Material, 0);
                RenderTexture.ReleaseTemporary(buffer0);

                // 进行垂直模糊
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, Material, 1);

                // 转移输出结果
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
