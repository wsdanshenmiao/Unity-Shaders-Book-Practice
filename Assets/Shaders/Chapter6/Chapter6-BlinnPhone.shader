Shader "Unity Shader Book/Chapter6/SpecularPixelLevel"
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
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vertex
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

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
                float3 posW : TEXCOORD;
                fixed3 normalW : COLOR;
            };

            v2f vertex(appdata vIn)
            {
                v2f vOut;
                vOut.posH = UnityObjectToClipPos(vIn.posL);
                vOut.posW = mul((float3x3)unity_ObjectToWorld, vIn.posL).rgb;
                // 将法线变换到世界坐标系中
                vOut.normalW = normalize(mul(vIn.normalL,(float3x3)unity_WorldToObject));
                return vOut;
            }

            fixed4 frag(v2f vIn) : SV_Target
            {
                // 获得环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 获取光向量
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(vIn.normalW,lightDir));

                float3 viewDir = normalize(_WorldSpaceCameraPos-vIn.posW);
                float3 halfDir = normalize(viewDir+lightDir);
                fixed3 specular = _Specular.rgb*_LightColor0.rgb*pow(saturate(dot(vIn.normalW,halfDir)),_Gloss);

                fixed3 color = diffuse + ambient + specular;

                return fixed4(color,1);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
