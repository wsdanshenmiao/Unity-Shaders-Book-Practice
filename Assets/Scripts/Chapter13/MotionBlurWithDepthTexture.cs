using UnityEditor;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase
{
    public Shader motionBlurShader;

    private Material m_MotionBlurMaterial;
    private Camera m_Camera;

    public Material material {
        get { m_MotionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, m_MotionBlurMaterial); return m_MotionBlurMaterial; }
    }

    public float blurSize = 0.8f;

    private Matrix4x4 m_PreViewProjectionMatrix;

    private void Awake()
    {
        m_Camera = GetComponent<Camera>();
    }

    private void OnEnable()
    {
        m_Camera.depthTextureMode = DepthTextureMode.Depth;
        m_PreViewProjectionMatrix = m_Camera.projectionMatrix * m_Camera.worldToCameraMatrix;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null){
            material.SetFloat("_BlurSize", blurSize);
            material.SetMatrix("_PreViewProjectionMatrix", m_PreViewProjectionMatrix);
            
            Matrix4x4 currentViewProjectionMatrix = m_Camera.projectionMatrix * m_Camera.worldToCameraMatrix;
            material.SetMatrix("_CurrentViewProjectionInvMatrix", currentViewProjectionMatrix.inverse);
            m_PreViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(src, dest, material);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }


}
