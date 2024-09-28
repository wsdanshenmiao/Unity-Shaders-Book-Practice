Shader "Unity Shader Book/Chapter10/RefectionMat"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _ReflectColor ("Refelct Color", Color) = (1,1,1,1)
        _ReflectAmount ("Reflect Amount", Range(0,1)) = 1
        _Cubemap ("Reflect Map", Cube) = "_Skybxo" {}   
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 posW : TEXCOORD0;
                float3 normalW : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            fixed4 _Color;
            fixed4 _ReflectColor;
            float _ReflectAmount;
            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posW = mul(unity_ObjectToWorld, v.vertex);
                o.normalW = normalize(UnityObjectToWorldNormal(v.normal));
                TRANSFER_SHADOW();
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.posW));
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.posW));
                float3 reflectW = reflect(-viewDir, i.normalW);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = _LightColor0.xyz * _Color.xyz * max(0, dot(i.normalW, viewDir));
                float3 reflection = texCUBE(_Cubemap, reflectW).rgb * _ReflectColor.xyz;

                UNITY_LIGHT_ATTENUATION(atten, i, i.posW);
                fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
