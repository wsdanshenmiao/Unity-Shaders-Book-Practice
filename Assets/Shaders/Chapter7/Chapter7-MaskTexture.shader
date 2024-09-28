Shader "Unity Shader Book/Chapter7/MaskTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "white" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Color ("Color", Color) = (1,1,1,1)
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            fixed4 _Color; 
            float _Gloss;

            struct appdata
            {
                float4 posL : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f
            {
                float4 posH : SV_POSITION;
                float2 uv :TEXCOORD0;
                float3 lightDirT : TEXCOORD1;
                float3 viewDirT : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.posH = UnityObjectToClipPos(v.posL);
                vOut.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                // 计算切线空间变换矩阵
                TANGENT_SPACE_ROTATION;
                vOut.lightDirT = mul(rotation, ObjSpaceLightDir(v.posL).xyz);
                vOut.viewDirT = mul(rotation, ObjSpaceViewDir(v.posL));

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDirT = normalize(i.lightDirT);
                float3 viewDirT = normalize(i.viewDirT);
                float3 halfDirT = normalize(lightDirT + viewDirT);

                // 获取法线
                float3 normalT = UnpackNormal(tex2D(_BumpMap, i.uv));
                normalT.xy *= _BumpScale;
                normalT.z = sqrt(1.0 - saturate(dot(normalT.xy, normalT.xy)));

                // 获取遮罩
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(lightDirT, normalT));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normalT,halfDirT)), _Gloss) * specularMask;
            
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
