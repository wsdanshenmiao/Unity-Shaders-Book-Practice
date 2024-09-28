Shader "Unity Shader Book/Chapter7/RampTexture"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) =(1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 32
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
                
            struct appdata
            {
                float4 posL : POSITION;
                float3 normalL : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 posH : SV_POSITION;
                float3 posW : TEXCOORD0;
                float3 normalW : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.posH = UnityObjectToClipPos(v.posL);
                vOut.posW = mul(unity_ObjectToWorld, v.posL).xyz;
                vOut.normalW = UnityObjectToWorldNormal(v.normalL);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalW = normalize(i.normalW);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.posW));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.posW));
                float3 halfDir = normalize(lightDir + viewDir);

                float halfLambert = 0.5 * dot(lightDir, normalW) + 0.5;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 albedo = tex2D(_RampTex, float2(halfLambert, halfLambert)).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, normalW)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
