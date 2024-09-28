Shader "Unity Shader Book/Chapter5/SimpleShader"
{
    Properties
    {
        // µ÷ºÍÑÕÉ«
        _Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;

            struct VertexIN
            {
                float4 posL : POSITION;
                float3 normal : NORMAL;
                float2 tex : TEXCOORD;
            };

            struct VertexOut
            {
                float4 posH : SV_POSITION;
                float3 color : COLOR;
            };

            VertexOut vert (VertexIN vIn)
            {
                VertexOut vOut;
                vOut.posH = UnityObjectToClipPos(vIn.posL);
                vOut.color = vIn.normal * 0.5 + fixed3(0.5,0.5,0.5);
                return vOut;
            }

            fixed4 frag (VertexOut vIn) : SV_Target
            {
                fixed3 color = vIn.color;
                color *= _Color.rgb;
                return fixed4(color,1.0);
            }

            ENDCG
        }
    }
}
