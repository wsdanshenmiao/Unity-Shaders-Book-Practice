Shader "Unity Shader Book/Chapter12/MotionBlur"
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

        sampler2D _MainTex;
        float _BlurAmount;

        v2f vert(appdata v)
        {
            v2f o;
            o.uv = v.uv;
            o.vertex = UnityObjectToClipPos(v.vertex);
            return o;
        }

        fixed4 fragRGB(v2f i) : SV_Target
        {
            return fixed4(tex2D(_MainTex, i.uv).rgb, 1 - _BlurAmount);
        }

        fixed4 fragA(v2f i) : SV_Target
        {
            return fixed4(tex2D(_MainTex, i.uv));
        }

        ENDCG

        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB
            ENDCG
        }

        Pass
        {
            Blend One Zero
            ColorMask A

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
    }
}
