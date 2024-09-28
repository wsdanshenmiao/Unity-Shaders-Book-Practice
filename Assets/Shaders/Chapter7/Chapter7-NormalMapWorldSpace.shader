Shader "Unity Shader Book/Chapter7/NormalMapWorldSpace"
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
                float4 tTow0:TEXCOORD1;
                float4 tTow1:TEXCOORD2;
                float4 tTow2:TEXCOORD3;
            };

            vTof vert(appData vIn)
            {
                vTof vOut;
                vOut.posH=UnityObjectToClipPos(vIn.posL);

                // ��ȡ��������
                vOut.uv.xy=vIn.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                vOut.uv.zw=vIn.uv.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;

                float3 posW = mul(unity_ObjectToWorld,vIn.posL);
                float3 normalW = normalize(UnityObjectToWorldNormal(vIn.normalL));
                float3 tangentW = normalize(UnityObjectToWorldDir(vIn.tangentL));
                float3 binormalW = cross(normalW,tangentW)*vIn.tangentL.w;

                vOut.tTow0 = float4(tangentW.x,binormalW.x,normalW.x,posW.x);
                vOut.tTow1= float4(tangentW.y,binormalW.y,normalW.y,posW.y);
                vOut.tTow2 = float4(tangentW.z,binormalW.z,normalW.z,posW.z);

                return vOut;
            }

            fixed4 frag(vTof vIn):SV_Target
            {
                float3 posW = float3(vIn.tTow0.w,vIn.tTow1.w,vIn.tTow2.w);

                float3 lightDir = normalize(UnityWorldSpaceLightDir(posW));
                float3 viewDir= normalize(UnityWorldSpaceViewDir(posW));

                float3 bump = UnpackNormal(tex2D(_BumpMap,vIn.uv.zw));
                bump.xy*=_BumpScale;
                bump.z = sqrt(1-saturate(dot(bump.xy,bump.xy)));

                bump = normalize(float3(dot(vIn.tTow0.xyz,bump),dot(vIn.tTow1.xyz,bump),dot(vIn.tTow2.xyz,bump)));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 albedo = tex2D(_MainTex, vIn.uv).rgb * _Color.rgb;
                fixed3 diffuse = albedo * _LightColor0.rgb * max(0, dot(lightDir, bump));
                fixed3 halfDir = normalize(lightDir+viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(halfDir,bump)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);
            }

            ENDCG

        }
    }
}
