using UnityEngine;
using UnityEngine.UI;

public class Bloom :PostEffectsBase
{
    public Shader bloomShader;
    private Material m_Material = null;
    public Material BloomMaterial{
        get { m_Material = CheckShaderAndCreateMaterial(bloomShader, m_Material); return m_Material; }
    }

    // 模糊迭代次数
    [Range(0, 4)]
    public int interator = 1;
    // 模糊范围
    [Range(0.2f, 3)]
    public float blurSpread = 0.6f;
    // 纹理的缩小比例,进行降采样
    [Range(1, 5)]
    public int downSample = 2;
    // 光照阈值
    [Range(0, 4)]
    public float luminanceThreshold = 0.6f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(BloomMaterial != null){
            BloomMaterial.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int width = src.width / downSample;
            int height = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            // 使用第一个Pass提取较亮区域
            Graphics.Blit(src, buffer0, BloomMaterial, 0);

            for (int i = 0; i < interator; ++i) {
                BloomMaterial.SetFloat("_BlurSize", 1 + i * blurSpread);

                // 进行水平模糊,输出模糊结果到buffer1
                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, BloomMaterial, 1);
                RenderTexture.ReleaseTemporary(buffer0);

                // 进行垂直模糊
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, BloomMaterial, 2);

                // 转移输出结果
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            // 使用第四个Pass进行混合
            BloomMaterial.SetTexture("_Bloom", buffer0);
            Graphics.Blit(src, dest, BloomMaterial, 3);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
