Shader "Unity Shader Book/Chapter8/AlphaBlendWithShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _AlphaScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normalW : TEXCOORD0;
                float3 posW : TEXCOORD1;
                float2 uv : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.pos = UnityObjectToClipPos(v.vertex);
                vOut.normalW = UnityObjectToWorldNormal(v.normal);
                vOut.posW = mul(unity_ObjectToWorld, v.vertex).xyz;
                vOut.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                TRANSFER_SHADOW(vOut);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(atten, i, i.posW);
                float3 normalW = normalize(i.normalW);
                float3 lightDirW = normalize(UnityWorldSpaceLightDir(i.posW));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalW, lightDirW));

                return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}