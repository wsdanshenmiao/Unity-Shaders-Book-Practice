Shader "Unity Shader Book/Chapter13/FogWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity ("_FogDensity", Float) = 1.0
        _FogColor ("_FogColor", Color) = (1,1,1,1)
        _FogStar ("_FogStar", Float) = 0.0
        _FogEnd ("_FogEnd", Float) = 1.0
        _FogFactor ("_FogFactor", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float4 uv : TEXCOORD0;
            float3 interpolatedRay : TEXCOORD1;
        };

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _FrustumCorners;
        float _FogDensity;
        fixed4 _FogColor;
        float _FogStar;
        float _FogEnd;
        float _FogFactor;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            float2 uv = v.uv;
            o.uv = uv.xyxy;

            int index = 0;
            if(uv.x < 0.5 && uv.y < 0.5){
                index = 0;
            } else if(uv.x > 0.5 && uv.y < 0.5){
                index = 1;
            } else if(uv.x > 0.5 && uv.y > 0.5){
                index = 2;
            } else{
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0){
                o.uv.zw.y = 1 - o.uv.zw.y;
                index = 3 - index;
            }
            #endif

            o.interpolatedRay = _FrustumCorners[index].xyz;

            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw));
            float3 posW = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

            float fogDensity = 0;
            #ifdef LINEAR
            fogDensity = (_FogEnd - posW.y) / (_FogEnd - _FogStar);
            #endif
            #ifdef EXPONENTIAL
            fogDensity = exp(-_FogFactor * posW.y);
            #endif
            #ifdef SQUARED
            fogDensity = exp(-pow(_FogFactor - posW.y, 2));
            #endif
            fogDensity = saturate(fogDensity * _FogDensity);
            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv.xy);
            col.rgb = lerp(col.rgb, _FogColor.rgb, fogDensity);
            return col;
        }
        ENDCG



        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_local _ LINEAR
            #pragma multi_compile_local _ EXPONENTIAL
            #pragma multi_compile_local _ SQUARED
            ENDCG
        }
    }
}
