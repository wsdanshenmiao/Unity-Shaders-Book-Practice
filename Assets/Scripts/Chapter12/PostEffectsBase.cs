using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
	// Called when need to create the material used by this effect
	protected Material CheckShaderAndCreateMaterial(Shader shader, Material material) {
		if (shader == null || !shader.isSupported) {
			return null;
		}
	
		material = material && material.shader ? material : new Material(shader);
		material.hideFlags = HideFlags.DontSave;
		return material ? material : null;
	}
}
