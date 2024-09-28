Shader "Unity Shader Book/Chapter12/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "../Common/Util.hlsl"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _BlurSize;
        float _LuminanceThreshold;

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        v2f vertExtractBright (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        fixed4 fragExtractBright (v2f i) : SV_Target
        {
            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv);
            fixed a = clamp(luminance(col) - _LuminanceThreshold, 0, 1);
            return col * a;
        }

        struct v2fBloom
        {
            float4 vertex : SV_POSITION;
            float4 uv :TEXCOORD0;
        };

        v2fBloom vertBloom(appdata v)
        {
            v2fBloom o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.uv;
            o.uv.zw = v.uv;
            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                o.uv.w = 1 - o.uv.w; 
            }
            #endif
            return o;
        }

        fixed4 fragBloom(v2fBloom i) : SV_Target
        {
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
        }
        ENDCG

        ZTest Always Cull Off ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }
        UsePass "Unity Shader Book/Chapter12/GaussionBlur/GAUSSION_BLUR_VERTICAL"
        UsePass "Unity Shader Book/Chapter12/GaussionBlur/GAUSSION_BLUR_HORIZONTAL"
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }

    }
    FallBack Off
}
