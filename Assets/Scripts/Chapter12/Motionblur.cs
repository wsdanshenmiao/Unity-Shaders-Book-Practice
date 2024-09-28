using System;
using UnityEngine;

public class Motionblur : PostEffectsBase
{
    public Shader MotionBlurShader;
    private Material m_MotionBlurMaterial;
    public Material MotionBlurMaterial{
        get { m_MotionBlurMaterial = CheckShaderAndCreateMaterial(MotionBlurShader, m_MotionBlurMaterial);
            return m_MotionBlurMaterial;
        }
    }

    [Range(0, 0.9f)]
    public float blurAmount = 0.6f;
    
    private RenderTexture accmulationTexture;

    private void OnDisable()
    {
        DestroyImmediate(accmulationTexture);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(MotionBlurMaterial != null){
            if(accmulationTexture == null ||
            accmulationTexture.width != src.width ||
            accmulationTexture.height != src.height){
                DestroyImmediate(accmulationTexture);
                accmulationTexture = new RenderTexture(src.width, src.height, 0);
                accmulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, accmulationTexture);
            }
            MotionBlurMaterial.SetFloat("_BlurAmount", blurAmount);

            Graphics.Blit(src, accmulationTexture, MotionBlurMaterial);
            Graphics.Blit(accmulationTexture, dest);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
