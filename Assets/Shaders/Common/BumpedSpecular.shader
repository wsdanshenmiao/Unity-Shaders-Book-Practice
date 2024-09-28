Shader "Unity Shader Book/Common/BumpedSpecular"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 32
        _Color ("Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        // Base Pass
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            fixed4 _Color;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 posW : TEXCOORD1;
                float3 lightDirT : TEXCOORD2;
                float3 viewDirT : TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.pos = UnityObjectToClipPos(v.vertex);
                vOut.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                vOut.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                vOut.posW = mul(unity_ObjectToWorld, v.vertex).xyz;

                TANGENT_SPACE_ROTATION;
                vOut.lightDirT = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                vOut.viewDirT = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                TRANSFER_SHADOW(vOut);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDirT = normalize(i.lightDirT);
                float3 viewDirT = normalize(i.viewDirT);
                float3 halfDir = normalize(viewDirT + lightDirT);

                float3 normalT = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                normalT.xy *= _BumpScale;
                normalT.z = sqrt(1 - saturate(dot(normalT.xy, normalT.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalT, lightDirT));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normalT, halfDir)), _Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, i.posW);

                return fixed4(ambient + (diffuse + specular) * atten, 1);
            }
            ENDCG
        }
        
        // Addition Pass
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            fixed4 _Color;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 posW : TEXCOORD1;
                float3 lightDirT : TEXCOORD2;
                float3 viewDirT : TEXCOORD3;
                SHADOW_COORDS(4)
            };


            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.pos = UnityObjectToClipPos(v.vertex);
                vOut.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                vOut.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                vOut.posW = mul(unity_ObjectToWorld, v.vertex);

                TANGENT_SPACE_ROTATION;
                vOut.lightDirT = mul(rotation, ObjSpaceLightDir(v.vertex));
                vOut.viewDirT = mul(rotation, ObjSpaceViewDir(v.vertex));

                TRANSFER_SHADOW(vOut);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDirT = normalize(i.lightDirT);
                float3 viewDirT = normalize(i.viewDirT);
                float3 halfDir = normalize(viewDirT + lightDirT);

                float3 normalT = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                normalT.xy *= _BumpScale;
                normalT.z = sqrt(1 - saturate(dot(normalT.xy, normalT.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalT, lightDirT));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normalT, halfDir)), _Gloss);
                UNITY_LIGHT_ATTENUATION(atten, i, i.posW);

                return fixed4((diffuse + specular) * atten, 1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
