Shader "Unity Shader Book/Chapter11/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _VerticalBillboard ("Vertical Billboard", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" "DisableBatching"="True" }
        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _VerticalBillboard;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                float3 center = float3(0,0,0);
                // 获取观察方向
                float3 cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                float3 normalDir = cameraPos - center;
                normalDir.y *= _VerticalBillboard;
                normalDir = normalize(normalDir);

                // 判断法线方向是否与向上的方向平行
                float3 upDir = abs(normalDir.y) > 0.99 ? float3(0,0,1) : float3(0,1,0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));

                // 获取当前顶点
                float3 offset = v.vertex.xyz - center;
                float3 localPos = center + offset.x * rightDir + offset.y * upDir + offset.z * normalDir;
                o.vertex = UnityObjectToClipPos(localPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                return color * _Color;
            }
            ENDCG
        }
    }
}
