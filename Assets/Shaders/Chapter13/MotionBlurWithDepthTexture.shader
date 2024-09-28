Shader "Unity Shader Book/Chapter13/MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float2 uv_Depth : TEXCOORD1;
        };

        sampler2D _MainTex;
        sampler2D _CameraDepthTexture;
        half4 _MainTex_TexelSize;
        float _BlurSize;
        float4x4 _CurrentViewProjectionInvMatrix;
        float4x4 _PreViewProjectionMatrix;

        v2f vert (appdata v)
        {
            
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            o.uv_Depth = v.uv;
            // 若为DirectX，翻转纹理坐标
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_Depth.y = 1 - o.uv_Depth.y;
			#endif
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // 获取当前像素的深度
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_Depth);
            #if defined(UNITY_REVERSED_Z)
	        depth = 1.0 - depth;
            #endif
            // 获取NDC空间坐标
            float4 posH = float4(2 * i.uv.x - 1, 2 * i.uv.y - 1, 2 * depth - 1, 1);
            // 变换到世界坐标
            float4 posW = mul(_CurrentViewProjectionInvMatrix, posH);
            posW /= posW.w;

            // 获取前一帧的世界坐标
            float4 prePosH = mul(_PreViewProjectionMatrix, posW);
            prePosH /= prePosH.w;
            float2 v = (posH - prePosH).xy * 0.5;

            fixed4 color = fixed4(0,0,0,0);
            float2 uv = i.uv;
            int it = 3;
            for(int i = 0; i < it; ++i){
                uv += v * _BlurSize;
                color += tex2D(_MainTex, uv);
            }
            color /= it;
            return fixed4(color.rgb, 1);
        }
        ENDCG

        Pass
        {
            ZTest Always Cull Off ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
