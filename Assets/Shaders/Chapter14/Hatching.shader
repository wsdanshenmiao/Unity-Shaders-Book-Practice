Shader "Unity Shader Book/Chapter14/Hatching"
{
    Properties
    {
        _Hatch0 ("Hatch 0", 2D) = "white" {}
        _Hatch1 ("Hatch 1", 2D) = "white" {}
        _Hatch2 ("Hatch 2", 2D) = "white" {}
        _Hatch3 ("Hatch 3", 2D) = "white" {}
        _Hatch4 ("Hatch 4", 2D) = "white" {}
        _Hatch5 ("Hatch 5", 2D) = "white" {}
        _Color ("Color Tine", Color) = (1,1,1,1)
        _TileFactor ("Tile Factor", Float) = 8.0
        _Outline ("Outline", Range(0, 1)) = 0.1
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "AutoLight.cginc"
        #include "Lighting.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 posW : TEXCOORD1;
            float3 hatchWeight0 : TEXCOORD2;
            float3 hatchWeight1 : TEXCOORD3;
            SHADOW_COORDS(4)
        };

        sampler2D _Hatch0;
        sampler2D _Hatch1;
        sampler2D _Hatch2;
        sampler2D _Hatch3;
        sampler2D _Hatch4;
        sampler2D _Hatch5;
        fixed4 _Color;
        float _TileFactor;

        v2f vertHatching (appdata v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord * _TileFactor;
            o.posW = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 normalW = UnityObjectToWorldNormal(v.normal);
            float3 lightDirW = normalize(WorldSpaceLightDir(v.vertex));

            float diff = max(dot(normalW, lightDirW), 0);
            float hatchFactor = diff * 7.0;
            o.hatchWeight0 = float3(0,0,0);
            o.hatchWeight1 = float3(0,0,0);
            if(hatchFactor > 6.0){
            }
            else if(hatchFactor > 5.0){
                o.hatchWeight0.x = hatchFactor - 5.0;
            }
            else if(hatchFactor > 4.0){
                o.hatchWeight0.x = hatchFactor - 4.0;
                o.hatchWeight0.y = 1.0 - o.hatchWeight0.x;
            }
            else if(hatchFactor > 3.0){
                o.hatchWeight0.y = hatchFactor - 3.0;
                o.hatchWeight0.z = 1.0 - o.hatchWeight0.y;
            }
            else if(hatchFactor > 2.0){
                o.hatchWeight0.z = hatchFactor - 2.0;
                o.hatchWeight1.x = 1.0 - o.hatchWeight0.z;
            }
            else if(hatchFactor > 1.0){
                o.hatchWeight1.x = hatchFactor - 1.0;
                o.hatchWeight1.y = 1.0 - o.hatchWeight1.x;
            }
            else {
                o.hatchWeight1.y = hatchFactor;
                o.hatchWeight1.z = 1.0 - o.hatchWeight1.y;
            }

            TRANSFER_SHADOW(o);

            return o;
        }

        fixed4 fragHatching (v2f i) : SV_Target
        {
            fixed4 hatchCol0 = tex2D(_Hatch0, i.uv) * i.hatchWeight0.x;
            fixed4 hatchCol1 = tex2D(_Hatch1, i.uv) * i.hatchWeight0.y;
            fixed4 hatchCol2 = tex2D(_Hatch2, i.uv) * i.hatchWeight0.z;
            fixed4 hatchCol3 = tex2D(_Hatch3, i.uv) * i.hatchWeight1.x;
            fixed4 hatchCol4 = tex2D(_Hatch4, i.uv) * i.hatchWeight1.y;
            fixed4 hatchCol5 = tex2D(_Hatch5, i.uv) * i.hatchWeight1.z;
            fixed4 whiteCol = fixed4(1,1,1,1) * (1 - i.hatchWeight0.x - i.hatchWeight0.y - i.hatchWeight0.z 
                - i.hatchWeight1.x - i.hatchWeight1.y - i.hatchWeight1.z);

            fixed4 col = hatchCol0 + hatchCol1 + hatchCol2 + hatchCol3 + hatchCol4 + hatchCol5 + whiteCol;
            UNITY_LIGHT_ATTENUATION(atten, i, i.posW);
            
            return fixed4(col.rgb * _Color.rgb * atten, 1);
        }
        ENDCG

        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        
        UsePass "Unity Shader Book/Chapter14/ToonShading/OUTLINE"

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vertHatching
            #pragma fragment fragHatching
            #pragma multi_compile_fwdbase
            ENDCG
        }
    }
    FallBack "Diffuse"
}
