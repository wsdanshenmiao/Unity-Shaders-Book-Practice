Shader "Unity Shader Book/Chapter15/WaterWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiceMap ("Noice Map", 2D) = "bump" {}
        _CubeMap ("Cube Map", Cube) = "_Skybox" {}
        _MoveXSpeed ("Move X Speed", Range(-0.1,0.1)) = 0.01
        _MoveYSpeed ("Move Y Speed", Range(-0.1,0.1)) = 0.01
        _Distortion ("Distortion", Range(0,100)) = 10
        _Color ("Color", Color) = (0,0.15,0.115,0.1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}

		GrabPass { "_RefractionTex" }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 posS : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiceMap;
            float4 _NoiceMap_ST;
            samplerCUBE _CubeMap;
            float _MoveXSpeed;
            float _MoveYSpeed;
            float _Distortion;
            float4 _Color;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // 计算屏幕空间坐标
                o.posS = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _NoiceMap);

                float3 posW = mul(unity_ObjectToWorld, v.vertex);
                float3 normalW = UnityObjectToWorldNormal(v.normal);
                float3 tangentW = UnityObjectToWorldDir(v.tangent.xyz);
                float3 binormal = cross(normalW, tangentW) * v.tangent.w;
                
                // 封装切线到世界空间的变换矩阵和世界坐标
                o.TtoW0 = float4(tangentW.x, binormal.x, normalW.x, posW.x);
                o.TtoW1 = float4(tangentW.y, binormal.y, normalW.y, posW.y);
                o.TtoW2 = float4(tangentW.z, binormal.z, normalW.z, posW.z);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 posW = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(posW));
                float2 speed = _Time.y * float2(_MoveXSpeed, _MoveYSpeed);

                // 模拟两层交叉的水面
                float3 normal1 = UnpackNormal(tex2D(_NoiceMap, i.uv.zw + speed)).rgb;
                float3 normal2 = UnpackNormal(tex2D(_NoiceMap, i.uv.zw - speed)).rgb;
                float3 normal = normalize(normal1 + normal2);

                // 采样偏移量
                float2 offset = normal.xy * _Distortion * _RefractionTex_TexelSize.xy;
                // 深度越深偏移量越大
                i.posS.xy = i.posS.z * offset + i.posS.xy;
                float3 refracColor = tex2D(_RefractionTex, i.posS.xy / i.posS.w).rgb;

                // 转换到世界空间
                normal = normalize(float3(dot(i.TtoW0.xyz, normal), dot(i.TtoW1.xyz, normal), dot(i.TtoW2.xyz, normal)));
                float3 texColor = tex2D(_MainTex, i.uv.xy + speed).rgb;
                float3 reflectDir = reflect(-viewDir, normal);
                float3 reflectColor = texCUBE(_CubeMap, reflectDir).rgb * texColor * _Color.rgb;
                
                // 计算菲涅尔项
                float fresnel = pow(1 - saturate(dot(viewDir, normal)), 4);
                float3 col = reflectColor * fresnel + refracColor * (1 - fresnel);

                return float4(col, 1);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
