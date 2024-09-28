using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetDepthNormal : MonoBehaviour
{
    public enum TexType{
        Depth, Normal, None
    };

    public Shader getDepthNormalShader;
    public TexType texType = TexType.Depth;

    private Material m_Material;
    private Camera m_Camera;

    public RenderTexture depthTex;
    public RenderTexture normalTex;

    private void Awake()
    {
        m_Camera = GetComponent<Camera>();
        m_Camera.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    private void Start()
    {
        m_Material = new Material(getDepthNormalShader);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_Material != null)
        {
            if (depthTex == null)
            {
                depthTex = new RenderTexture(src.width, src.height, 0);
                depthTex.filterMode = FilterMode.Bilinear;
            }
            if (normalTex == null)
            {
                normalTex = new RenderTexture(src.width, src.height, 0);
                normalTex.filterMode = FilterMode.Bilinear;
            }
            switch(texType){
                case TexType.Depth:
                    Graphics.Blit(src, dest, m_Material, 0); break;
                case TexType.Normal:
                    Graphics.Blit(src, dest, m_Material, 1); break;
                case TexType.None:
                    Graphics.Blit(src, dest); break;
            }
        }
        else {
            Graphics.Blit(src, dest);
        }
    }
}
