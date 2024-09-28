Shader "Unity Shader Book/Chapter7/SingleTex"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8,256)) = 32
        _Color ("Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
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

            struct appdata
            {
                float4 posL:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD;
            };

            struct vtof
            {
                float4 posH:POSITION;
                float3 posW:TEXCOORD0;
                float3 normalW:NORMAL;
                float2 uv:TEXCOORD2;
            };

            vtof vert(appdata vIn)
            {
                vtof vOut;
                vOut.posH = UnityObjectToClipPos(vIn.posL);
                vOut.posW = mul((float3x3)unity_ObjectToWorld, vIn.posL);
                vOut.normalW = normalize(UnityObjectToWorldNormal(vIn.normal));
                vOut.uv = vIn.texcoord*_MainTex_ST.xy+_MainTex_ST.zw;
                return vOut;
            }

            fixed4 frag(vtof vIn) :SV_Target
            {
                float3 lightDir = normalize(UnityWorldSpaceLightDir(vIn.posW));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(vIn.posW));
                fixed3 albedo = tex2D(_MainTex,vIn.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(lightDir,vIn.normalW));
                float3 halfDir = normalize(lightDir+viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(vIn.normalW,halfDir)),_Gloss);
                fixed3 color = ambient+diffuse+specular;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
