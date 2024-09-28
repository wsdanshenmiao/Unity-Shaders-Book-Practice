Shader "Unity Shader Book/Chapter6/SpecularVertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 32
    }
    SubShader
    {
        Pass
        {
            Tags{"LighteMod"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 posL : POSITION;
                float3 normalL :NORMAL;
            };


            struct v2f
            {
                float4 posH : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f vOut;
                vOut.posH = UnityObjectToClipPos(v.posL);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; 

                float3 normalW = normalize(mul(v.normalL,(float3x3)unity_WorldToObject));
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _Diffuse.rgb*_LightColor0.rgb*saturate(dot(normalW,lightDir));

                float3 viewDir = normalize(_WorldSpaceCameraPos-mul(unity_ObjectToWorld,v.posL).rgb);
                float3 halfDir = normalize(viewDir+lightDir);
                fixed3 specular = _Specular.rgb*_LightColor0.rgb*pow(saturate(dot(normalW,halfDir)),_Gloss);

                vOut.color = ambient+diffuse+specular;

                return vOut;
            }

            fixed3 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
