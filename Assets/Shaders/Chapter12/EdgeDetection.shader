Shader "Unity Shader Book/Chapter12/EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            ZTest Always ZWrite Off Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "../Common/Util.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                // 周围的纹理坐标
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 像素的梯度
                half edge = Sobel(_MainTex, i.uv);
                // 插值背景
                fixed4 texColor = lerp(tex2D(_MainTex, i.uv[4]), _BackgroundColor, _EdgeOnly);
                return lerp(texColor, _EdgeColor, edge);
            }
            ENDCG
        }
    }
}
