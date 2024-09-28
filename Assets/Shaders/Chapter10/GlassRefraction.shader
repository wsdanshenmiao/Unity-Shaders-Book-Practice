Shader "Unity Shader Book/Chapter10/GlassRefraction"
{
    Properties
    {
        _MainTex ("_Main Texture", 2D) = "white" {}
        _BumpMap ("Normal Map",2D) = "white" {}
        _Distortion ("Distortion", Range(0,100)) = 10
        _CubeMap ("Cube Map", Cube) = "_Skybox"{}
        _RefractAmount ("Refraction", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100

        GrabPass{"_RefractionTex"}
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 scrPos : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _Distortion;
            samplerCUBE _CubeMap;
            float _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);
                o.scrPos = ComputeGrabScreenPos(o.pos);

                float3 posW = mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 tangentW = UnityObjectToWorldDir(v.tangent.xyz);
                float3 normalW  = UnityObjectToWorldNormal(v.normal);
                float3 binormal = cross(normalW, tangentW) * v.tangent.w;

                o.TtoW0 = float4(tangentW.x,binormal.x,normalW.x,posW.x);
                o.TtoW1 = float4(tangentW.y,binormal.y,normalW.y,posW.y);
                o.TtoW2 = float4(tangentW.z,binormal.z,normalW.z,posW.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 posW = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(posW));

                float3 bump  = UnpackNormal(tex2D(_BumpMap, i.uv.zw)).xyz;
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy += offset;

                float3 refrColor = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).xyz;
                
                bump = normalize(float3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

                float3 reflDir = reflect(-viewDir, bump);
                float3 texColor = tex2D(_MainTex, i.uv.xy).xyz;
                float3 reflColor = texCUBE(_CubeMap, reflDir).xyz * texColor;

                float3 color = refrColor * _RefractAmount + reflColor * (1 - _RefractAmount);

                return float4 (color,1);
            }
            ENDCG
        }
    }
    FallBack"Diffuse"
}
