Shader "Unity Shader Book/Chapter9/ForwardRendering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            float4 _Specular;
            fixed4 _Color;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normalL : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normalW : TEXCOORD1;
                float3 posW : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.vertex = UnityObjectToClipPos(v.vertex);
                vOut.posW = mul(unity_ObjectToWorld, v.vertex);
                vOut.normalW = UnityObjectToWorldNormal(v.normalL);
                vOut.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalW = normalize(i.normalW);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.posW));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.posW));
                float3 halfDir = normalize(viewDir + lightDir);

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalW, lightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normalW, halfDir)), _Gloss);
                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular) * atten,1);
            }
            ENDCG
        }
        

        //Addition Pass
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
            float4 _Specular;
            fixed4 _Color;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normalL : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normalW : TEXCOORD1;
                float3 posW : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.vertex = UnityObjectToClipPos(v.vertex);
                vOut.posW = mul(unity_ObjectToWorld, v.vertex);
                vOut.normalW = UnityObjectToWorldNormal(v.normalL);
                vOut.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return vOut;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
            #else
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.posW.xyz);
            #endif

                float3 normalW = normalize(i.normalW);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.posW));
                float3 halfDir = normalize(viewDir + lightDir);

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normalW, lightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normalW, halfDir)), _Gloss);

			#ifdef USING_DIRECTIONAL_LIGHT
				fixed atten = 1.0;
			#else
				#if defined (POINT)
				    float3 lightCoord = mul(unity_WorldToLight, float4(i.posW, 1)).xyz;
				    fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#elif defined (SPOT)
				    float4 lightCoord = mul(unity_WorldToLight, float4(i.posW, 1));
				    fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#else
				    fixed atten = 1.0;
				#endif
			#endif
                return fixed4((diffuse + specular) * atten, 1);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
