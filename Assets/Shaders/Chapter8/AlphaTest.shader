Shader "Unity Shader Book/Chapter8/AlphaTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Cutoff ("Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Cutoff;

            struct appdata
            {
                float4 posL : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 posH : SV_POSITION;
                float3 normalW : TEXCOORD0;
                float3 posW : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.posH = UnityObjectToClipPos(v.posL);
                vOut.normalW = UnityObjectToWorldNormal(v.normal);
                vOut.posW = mul(unity_ObjectToWorld, v.posL).xyz;
                vOut.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalW = normalize(i.normalW);
                float3 lightDirW = normalize(UnityWorldSpaceLightDir(i.posW));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                clip(texColor.a - _Cutoff);

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalW, lightDirW));

                return fixed4(ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
}
