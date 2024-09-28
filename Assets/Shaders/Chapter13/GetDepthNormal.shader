Shader "Unity Shader Book/Chapter13/GetDepthNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        #include "HLSLSupport.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        sampler2D _MainTex;
        sampler2D _CameraDepthNormalsTexture;

        v2f vert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        fixed4 fragDepth(v2f i) : SV_TARGET
        {
            float depth;
            float3 normal;
            DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
            return fixed4(depth, depth, depth, 1);
        }

        fixed4 fragNormal(v2f i) : SV_TARGET
        {
            float depth;
            float3 normal;
            DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
            return fixed4(normal * 0.5 + 0.5, 1);
        }

        ENDCG
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragDepth
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragNormal
            ENDCG
        }
    }
}
