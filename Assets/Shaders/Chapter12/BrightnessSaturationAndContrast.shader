Shader "Unity Shader Book/Chapter12/BrightnessSaturationAndContrast"
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

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed3 color = texColor.rgb;

                // 亮度
                color *= _Brightness;
                // 饱和度
                fixed luminance = 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                color = lerp(luminanceColor, color, _Saturation);
                // 对比度
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                color = lerp(avgColor, color, _Contrast);

                return fixed4(color, texColor.a);
            }
            ENDCG
        }
    }
}
