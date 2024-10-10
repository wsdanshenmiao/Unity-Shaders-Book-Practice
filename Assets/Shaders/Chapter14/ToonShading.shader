Shader "Unity Shader Book/Chapter14/ToonShading"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        // 漫反射色调渐变纹理
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _Color ("Color Tine", Color) = (1,1,1,1)
        // 边缘线
        _Outline ("Out Line", Range(0, 1)) = 0.1
        _OutlineColor ("Out Line Color", Color) = (1,1,1,1)
        // 高光颜色
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        // 高光阈值
        _SpecularThreshold ("Specular Threshold", Range(0.9, 1)) = 0.9
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"

        sampler2D _MainTex;
        float4 _MainTex_ST;
        // 漫反射色调渐变纹理
        sampler2D _Ramp;
        fixed4 _Color;
        // 边缘线
        float _Outline;
        fixed4 _OutlineColor;
        // 高光颜色
        fixed4 _SpecularColor;
        // 高光阈值
        float _SpecularThreshold;

        struct appdataOutline
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
        };

        struct v2fOutline
        {
            float4 pos : SV_POSITION;
        };

        v2fOutline vertOutline(appdataOutline v)
        {
            v2fOutline o;
            float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
            float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
            normal.z = -0.5;
            pos += float4(normal, 0) * _Outline;
            o.pos = mul(UNITY_MATRIX_P, pos);
            return o;
        }

        fixed4 fragOutline(v2fOutline i) : SV_Target
        {
            return fixed4(_OutlineColor.rgb, 1);
        }


        struct appdataLight
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float4 texcoord : TEXCOORD0;
        };

        struct v2fLight
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 normalW : TEXCOORD1;
            float4 posW : TEXCOORD2;
            SHADOW_COORDS(3)
        };

        v2fLight vertLight(appdataLight v)
        {
            v2fLight o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            o.normalW = UnityObjectToWorldNormal(v.normal);
            o.posW = mul(unity_ObjectToWorld, v.vertex);
            TRANSFER_SHADOW(o);
            return o;
        }

        fixed4 fragLight(v2fLight i) : SV_Target
        {
            // 计算参数
            float3 normalW = normalize(i.normalW);
            float3 lightDirW = normalize(UnityWorldSpaceLightDir(i.posW));
            float3 viewDirW = normalize(UnityWorldSpaceViewDir(i.posW));
            float3 halfDir = normalize(lightDirW + viewDirW);
            UNITY_LIGHT_ATTENUATION(atten, i, i.posW);

            // 计算反照率
            fixed4 texcol = tex2D(_MainTex, i.uv);
            fixed3 albedo = texcol.rgb * _Color.rgb;

            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
            // 使用渐变纹理
            float diff = dot(lightDirW, normalW);
            // 映射到[0,1]
            diff = (diff * 0.5 + 0.5);
            fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;
            // 高光
            float spec = dot(normalW, halfDir);
            float w = fwidth(spec) * 2;
            fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * lerp(0, 1, smoothstep(-w, w, spec - _SpecularThreshold));
            // 让阈值为1时，高光彻底消失
            specular *= step(0.0001, 1 - _SpecularThreshold);

            return fixed4(ambient + (diffuse + specular) * atten, texcol.a);
        }

        ENDCG

		Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            NAME "OUTLINE"
            Cull Front
            CGPROGRAM
            #pragma vertex vertOutline
            #pragma fragment fragOutline
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Back
            CGPROGRAM
            #pragma vertex vertLight
            #pragma fragment fragLight
            #pragma multi_compile_fwdbase
            ENDCG
        }
    }
    FallBack "Diffuse"
}
