Shader "Unity Shader Book/Chapter6/DiffuseVertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
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

            struct a2f
            {
                float4 posL : POSITION;
                float3 normalL : NORMAL;
            };

            struct v2f
            {
                float4 posH : SV_POSITION;
                float3 color : COLOR;
            };

            v2f vertex(a2f vIn)
            {
                v2f vOut;
                vOut.posH = UnityObjectToClipPos(vIn.posL);
                
                // 获得环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 将法线变换到世界坐标系中
                fixed3 normalW = normalize(mul(vIn.normalL,(float3x3)unity_WorldToObject)); 

                // 获取光向量
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(normalW,lightDir));

                vOut.color = diffuse + ambient;

                return vOut;
            }

            fixed3 frag(v2f vIn) : SV_Target
            {
                return vIn.color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
