Shader "Unity Shader Book/Chapter7/NormalMapTangentSpace"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 32
        _Color ("Color Tint", Color) = (1,1,1,1)
        _BumpMap("BunpMap",2D)="bump"{}
        _BumpScale("BumpScale",Float)=1.0
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float _Gloss;
            fixed4 _Specular;
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            struct appData
            {
                float4 posL:POSITION;
                float4 uv:TEXCOORD0;
                float4 tangentL:TANGENT;
                float3 normalL:NORMAL;
            };
            
            struct vTof
            {
                float4 posH:SV_POSITION;
                float4 uv:TEXCOORD0;
                fixed3 lightDir:TEXCOORD1;
                fixed3 viewDir:TEXCOORD2;
            };

            vTof vert(appData vIn)
            {
                vTof vOut;
                vOut.posH=UnityObjectToClipPos(vIn.posL);

                // 获取纹理坐标
                vOut.uv.xy=vIn.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                vOut.uv.zw=vIn.uv.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;

                // 副法线
                float3 binormal = cross(normalize(vIn.normalL),normalize(vIn.tangentL.xyz))*vIn.tangentL.w;
                // 切线空间变换矩阵
                float3x3 rotation=float3x3(vIn.tangentL.xyz,binormal,vIn.normalL);
                vOut.lightDir = mul(rotation,ObjSpaceLightDir(vIn.posL)).xyz;
                vOut.viewDir =mul(rotation,ObjSpaceViewDir(vIn.posL)).xyz;

                return vOut;
            }

            fixed4 frag(vTof vIn):SV_Target
            {
                fixed3 tangentLightDir = normalize(vIn.lightDir);
                fixed3 trangentViewDir = normalize(vIn.viewDir);

                // 获取法线
                fixed4 packNormal = tex2D(_BumpMap,vIn.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packNormal);

                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 albedo = tex2D(_MainTex,vIn.uv).rgb*_Color.rgb;
                fixed3 diffuse = albedo*_LightColor0.rgb*max(0,dot(tangentLightDir,tangentNormal));
                fixed3 halfDir = normalize(tangentLightDir+trangentViewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(halfDir,tangentNormal)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);
            }

            ENDCG

        }
    }
}
