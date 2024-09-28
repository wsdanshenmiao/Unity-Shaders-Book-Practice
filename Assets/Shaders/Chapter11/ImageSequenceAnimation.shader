Shader "Unity Shader Book/Chapter11/ImageSequenceAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ( "Color" , Color) = (1,1,1,1)
        _HorizontalCount("HorizontalCount", Float) = 4
        _VerticalCount("VerticalCount", Float) = 4
        _Speed("Speed", Range(1,100)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector" = "true" }
        Tags { "LightMode"="ForwardBase" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
            float4 _MainTex_ST;
            fixed4 _Color;
            float _HorizontalCount;
            float _VerticalCount;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = floor(_Time.y * _Speed);
                float row = floor(time / _HorizontalCount);
                float column = time - row * _VerticalCount;

                // 每个小纹理的纹理坐标
                half2 uv = i.uv + half2(column, -row);
                uv.x /= _HorizontalCount;
                uv.y /= _VerticalCount;

                fixed4 color = tex2D(_MainTex, uv);
                color.rgb *= _Color.rgb;

                return color;
            }
            ENDCG
        }
    }
}
