Shader "Unity Shader Book/Chapter15/Dissolve"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0.5
        _LineWidth ("Line Width", Float) = 0.05
        _BumpMap ("Normal Texture", 2D) = "white" {}
        _NoiceMap ("Noice Texture", 2D) = "white" {}
        _DissolveFirstColor ("Dissolve First Color", Color) = (1,1,1,1)
        _DissolveSecondColor ("Dissolve Second Color", Color)= (1,1,1,1)
    }
    SubShader
    {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
			Tags { "LightMode"="ForwardBase" }
            // 消融时会看到背面
            Cull Off
            CGPROGRAM
            #pragma vertex vertDissolve
            #pragma fragment fragDissolve
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
    
            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
    
            struct v2fDissolve
            {
                float4 pos : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvNoiceMap : TEXCOORD2;
                float3 posW : TEXCOORD3;
                float3 lightDirT : TEXCOORD4;
                SHADOW_COORDS(5)
            };
    
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DissolveAmount;
            float _LineWidth;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            sampler2D _NoiceMap;
            float4 _NoiceMap_ST;
            fixed4 _DissolveFirstColor;
            fixed4 _DissolveSecondColor;
    
            v2fDissolve vertDissolve (appdata v)
            {
                v2fDissolve o;
                o.pos = UnityObjectToClipPos(v.vertex);
    
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.uv, _BumpMap);
                o.uvNoiceMap = TRANSFORM_TEX(v.uv, _NoiceMap);
    
                // float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w; \
                // float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal )
                TANGENT_SPACE_ROTATION;
                o.lightDirT = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
    
                o.posW = mul(unity_ObjectToWorld, v.vertex).xyz;
    
                TRANSFER_SHADOW(o);
    
                return o;
            }
    
            fixed4 fragDissolve (v2fDissolve i) : SV_Target
            {
                // 获取消融因子
                float dissolve = tex2D(_NoiceMap, i.uvNoiceMap).r;
                clip(dissolve - _DissolveAmount);
    
                float3 lightDirT = normalize(i.lightDirT);
                float3 normalT = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));
    
                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse  = _LightColor0.rgb * albedo * max(0, dot(lightDirT, normalT));
    
                float t = 1 - smoothstep(0, _LineWidth, dissolve - _DissolveAmount);
                fixed3 dissolveColor = lerp(_DissolveFirstColor, _DissolveSecondColor, t);
                dissolveColor = pow(dissolveColor, 5);
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.posW);
                fixed3 color = lerp(ambient + diffuse * atten, dissolveColor, t * step(0.0001, _DissolveAmount));
    
                return fixed4(color, 1);
            }    
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ShadowCaster"}
            Cull Off

            CGPROGRAM
            #pragma vertex vertShadow
            #pragma fragment fragShadow
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            sampler2D _NoiceMap;
            float4 _NoiceMap_ST;
            float _DissolveAmount;

            struct v2fShadow
            {
                V2F_SHADOW_CASTER;
                float2 uvBumpMap : TEXCOORD0;
            };
    
            v2fShadow vertShadow(appdata_base v)
            {
                v2fShadow o;
    
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _NoiceMap);
    
                return o;
            }
    
            fixed4 fragShadow(v2fShadow i) : SV_Target
            {
                float dissolve = tex2D(_NoiceMap, i.uvBumpMap);
                clip(dissolve - _DissolveAmount);
                SHADOW_CASTER_FRAGMENT(i)
            }    
            ENDCG
        }
    }
    FallBack "Diffuse"
}
