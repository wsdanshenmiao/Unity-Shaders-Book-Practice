Shader "Unity Shader Bool/Chapter13/EdgeDetectNormalAndDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 0
        _EdgeColor ("Edge Color", Color) = (0,0,0,0)
        _BackgroundColor ("Edge Color", Color) = (1,1,1,1)
        _SampleDistance ("Sample Distance", Float) = 1
        _Sensitivity ("Sensitivity", Vector) = (0,0,0,0)
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "../Common/Util.hlsl"

        struct v2f
        {
            half2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _EdgeOnly;
        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;
        float _SampleDistance;
        float4 _Sensitivity;
        sampler2D _CameraDepthNormalsTexture;

        v2f vert (appdata_img v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;
            o.uv[0] = uv;
            
            #ifdef UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                uv.y = 1 - uv.y;
            }
            #endif
            o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _SampleDistance;
            o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _SampleDistance;
            o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDistance;
            o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _SampleDistance;

            return o;
        }

        fixed4 fragRobertsCrossDepthAndNormal (v2f i) : SV_Target
        {
            half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
            half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
            half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
            half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

            half edge = 1;
            edge *= CheckSame(sample1, sample2, _Sensitivity.xy);
            edge *= CheckSame(sample3, sample4, _Sensitivity.xy);

            fixed4 texColor = lerp(tex2D(_MainTex, i.uv[0]), _BackgroundColor, _EdgeOnly);
            fixed4 col = lerp(_EdgeColor, texColor, edge);
            return col;
        }
        ENDCG

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRobertsCrossDepthAndNormal
            ENDCG
        }
    }
    FallBack Off
}
