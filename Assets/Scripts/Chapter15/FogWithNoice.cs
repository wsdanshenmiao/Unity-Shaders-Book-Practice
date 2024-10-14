using UnityEngine;

public class FogWithNoice : PostEffectsBase
{
    public enum FogMode {
        Linear, Exponential, Squared
    };
    public Shader fogShader;

    private Material m_FogMaterial;
    public Material material {
        get { m_FogMaterial = CheckShaderAndCreateMaterial(fogShader, m_FogMaterial); return m_FogMaterial; }
    }

    private Camera m_Camera;
    public Camera myCamera{
        get{ if (m_Camera == null) m_Camera = GetComponent<Camera>(); return m_Camera; }
    }

    public FogMode fogMode = FogMode.Linear;
    // 雾的散射率
    public float fogDensity = 1.0f;
    public Color fogColor = Color.white;
    public float fogFactor = 1.0f;
    // 雾的起点高度
    public float fogStar = 0.0f;
    // 雾的终点高度
    public float fogEnd = 1.0f;

    void OnEnable() {
		myCamera.depthTextureMode |= DepthTextureMode.Depth;
	}


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null){
            Matrix4x4 frustumCorners = Matrix4x4.identity;
            Transform cameraTrans = myCamera.transform;
            float halfHeight = myCamera.nearClipPlane * Mathf.Tan(myCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);
            Vector3 toTop = cameraTrans.up * halfHeight;
            Vector3 toRight = cameraTrans.right * halfHeight * myCamera.aspect;

            Vector3[] frustumPoints = new Vector3[4];
            // 左下角的点
            frustumPoints[0] = cameraTrans.forward * myCamera.nearClipPlane - toTop - toRight;
            // 右下角的点
            frustumPoints[1] = cameraTrans.forward * myCamera.nearClipPlane - toTop + toRight;
            // 右上角的点
            frustumPoints[2] = cameraTrans.forward * myCamera.nearClipPlane + toTop + toRight;
            // 左上角的点
            frustumPoints[3] = cameraTrans.forward * myCamera.nearClipPlane + toTop - toRight;
            float scale = frustumPoints[0].magnitude / myCamera.nearClipPlane;
            for (int i = 0; i < frustumPoints.Length; ++i){
                frustumCorners.SetRow(i, frustumPoints[i].normalized * scale);
            }

            switch (fogMode)
            {
                case FogMode.Linear:{
                        material.EnableKeyword("LINEAR");
                        material.DisableKeyword("EXPONENTIAL");
                        material.DisableKeyword("SQUARED");
                        break;
                }
                case FogMode.Exponential:{
                        material.EnableKeyword("EXPONENTIAL");
                        material.DisableKeyword("LINEAR");
                        material.DisableKeyword("SQUARED");
                        break;
                }
                case FogMode.Squared:{
                        material.EnableKeyword("SQUARED");
                        material.DisableKeyword("LINEAR");
                        material.DisableKeyword("EXPONENTIAL");
                        break;
                }
                default:
                    break;
            }
            material.SetMatrix("_FrustumCorners", frustumCorners);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStar", fogStar);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetFloat("_FogFactor", fogFactor);

            Graphics.Blit(src, dest, material);
        }
        else{
            Graphics.Blit(src, dest);
        }
    }
}
