Shader "Unity Shader Book/Chapter12/GaussionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        ZTest Always ZWrite Off Cull Off

        CGINCLUDE
        
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            half2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;

        v2f vertBlurVertical (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv - half2(0.0, 2.0 * _MainTex_TexelSize.y * _BlurSize);
            o.uv[1] = v.uv - half2(0.0, 1.0 * _MainTex_TexelSize.y * _BlurSize);
            o.uv[2] = v.uv;
            o.uv[3] = v.uv + half2(0.0, 1.0 * _MainTex_TexelSize.y * _BlurSize);
            o.uv[4] = v.uv + half2(0.0, 2.0 * _MainTex_TexelSize.y * _BlurSize);

            return o;
        }

        v2f vertBlurHorizontal(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv - half2(2.0 * _MainTex_TexelSize.x * _BlurSize, 0.0);
            o.uv[1] = v.uv - half2(1.0 * _MainTex_TexelSize.x * _BlurSize, 0.0);
            o.uv[2] = v.uv;
            o.uv[3] = v.uv + half2(1.0 * _MainTex_TexelSize.x * _BlurSize, 0.0);
            o.uv[4] = v.uv + half2(2.0 * _MainTex_TexelSize.x * _BlurSize, 0.0);
            
            return o;
        }

        fixed4 fragBlur(v2f i) : SV_Target
        {
            float weight[3] = {0.0545, 0.2442, 0.4026};

            fixed3 sum = tex2D(_MainTex, i.uv[2]).rgb * weight[2];

            for(int j = 0; j < 2; ++j){
                sum += tex2D(_MainTex, i.uv[j]).rgb * weight[j];
                sum += tex2D(_MainTex, i.uv[4 - j]).rgb * weight[j];
            }

            return fixed4(sum, 1);
        }

        ENDCG

        Pass
        {
            NAME "GAUSSION_BLUR_VERTICAL"
            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur
            ENDCG
        }

        Pass
        {
            NAME "GAUSSION_BLUR_HORIZONTAL"
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur
            ENDCG
        }
    }
}
