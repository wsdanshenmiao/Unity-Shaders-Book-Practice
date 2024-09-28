using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering;
using UnityEngine;

public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;

    private Texture2D m_GenerationTexture = null; 

    #region Material Properties
    [SerializeField, SetProperty("TextureWidth")]

    private int m_TextureWidth = 512; 
    public int TextureWidth{
        get{
            return m_TextureWidth;
        }
        set{
            m_TextureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BackgroundColor")]
    private Color m_BackgroundColor = Color.white;
    public Color BackgroundColor{
        get{
            return m_BackgroundColor;
        }
        set{
            m_BackgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("CircleColor")]
    private Color m_CircleColor = Color.yellow;
    public Color CircleColor{
        get{
            return m_CircleColor;
        }
        set{
            m_CircleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BlurFactor")]
    private float m_BlurFactor = 2.0f;
    public float BlurFactor{
        get{
            return m_BlurFactor;
        }
        set{
            m_BlurFactor = value;
            _UpdateMaterial();
        }
    }

    #endregion

    void Start()
    {
        if(material == null){
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer == null){
                Debug.Log("Cannot Find Renderer");
                return;
            }
            material = renderer.sharedMaterial;
        }
        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if(material != null){
            m_GenerationTexture = _GenerationProceduralTexture();
            material.SetTexture("_MainTex",m_GenerationTexture);
        }
    }

    private Color _MixColor(Color dest, Color src, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(dest.r, src.r, mixFactor);
        mixColor.g = Mathf.Lerp(dest.g, src.g, mixFactor);
        mixColor.b = Mathf.Lerp(dest.b, src.b, mixFactor);
        mixColor.a = Mathf.Lerp(dest.a, src.a, mixFactor);
        return mixColor;
    }

    private Texture2D _GenerationProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(TextureWidth, TextureWidth); 
        float circleInterval = TextureWidth / 4.0f;
        float radius = TextureWidth / 10.0f;
        float edgeBlur = 1.0f / BlurFactor;

        for(int w = 0; w < TextureWidth; ++w){
            for(int h = 0; h < TextureWidth; ++h){
                Color pixel = BackgroundColor;
                // Draw nine circles one by one
				for (int i = 0; i < 3; i++) {
					for (int j = 0; j < 3; j++) {
						// Compute the center of current circle
						Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));

						// Compute the distance between the pixel and the center
						float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

						// Blur the edge of the circle
						Color color = _MixColor(CircleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));

						// Mix the current color with the previous color
						pixel = _MixColor(pixel, color, color.a);
					}
				}
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();

        return proceduralTexture;
    }
}
