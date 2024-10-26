Shader "Unity Shader Book/Chapter17/NormalExtrusion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ExtrusionAmount ("Extrusion Amount", Range(-0.1,0.1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow exclude_path:deferred exclude_path:prepass nometa
        #pragma target 3.0
        
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        sampler2D _BumpMap;
        fixed4 _Color;
        half _ExtrusionAmount;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void myvert(inout appdata_full v)
        {
            v.vertex.xyz += v.normal * _ExtrusionAmount;
        }

        void surf(Input i, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, i.uv_MainTex);
            o.Albedo = tex.rgb;
            o.Alpha = tex.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, i.uv_BumpMap));
        }

        half4 LightingCustomLambert(SurfaceOutput i, half3 lightDir, half atten)
        {
            half NdotL = dot(i.Normal, lightDir);
            half4 col;
            col.rgb = i.Albedo * _LightColor0.rgb * NdotL * atten;
            col.a = i.Alpha;
            return col;
        }

        void mycolor(Input i, SurfaceOutput o, inout fixed4 color)
        {
            color *= _Color;
        }

        ENDCG
    }
    FallBack "Legacy Shaders/Diffuse"
}
