Shader "Unity Shader Book/Chapter10/Fresnel"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _FresnelScale ("fresnel Scale", Range(0,1)) = 0.5
        _CubeMap ("Reflection Map", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue" = "Geometry"}
        Pass
        {
			Tags { "LightMode"="ForwardBase" }
            CGPROGRAM

            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 reflW : TEXCOORD0;
                float3 normalW : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 posW : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            float4 _Color;
            float _FresnelScale;
            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posW = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normalW = (UnityObjectToWorldNormal(v.normal));
                o.viewDir = (UnityWorldSpaceViewDir(o.posW));
                o.reflW = reflect(-o.viewDir, o.normalW);
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.normalW);
                float3 viewDir = normalize(i.viewDir);
                float3 ligthDir = normalize(UnityWorldSpaceLightDir(i.posW));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 reflection = texCUBE(_CubeMap, i.reflW).rgb;
                float fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(viewDir,normal) ,5);
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(ligthDir, normal));
                UNITY_LIGHT_ATTENUATION(atten, i, i.posW);

                fixed3 color = ambient + atten * lerp(diffuse, reflection, saturate(fresnel));

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}
