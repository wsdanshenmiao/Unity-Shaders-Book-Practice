#ifndef __UTIL__HLSL__
#define __UTIL__HLSL__

fixed luminance(fixed4 color)
{
    return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
}

half Sobel(sampler2D tex, half2 uv[9])
{
    // Sobel算子
    const half Gx[9] = {-1, 0, 1,
                        -2, 0, 2,
                        -1, 0, 1};
    const half Gy[9] = {-1, -2, -1,
                        0, 0, 0,
                        1, 2, 1};
    half texColor;
    half edgeX = 0;
    half edgeY = 0;
    for(int i = 0; i < 9; ++i){
        // 获取当前像素的亮度
        texColor = luminance(tex2D(tex, uv[i]));
        // 获取梯度
        edgeX += texColor * Gx[i];
        edgeY += texColor * Gy[i];
    }

    return abs(edgeX) + abs(edgeY);
}

half CheckSame(half4 center, half4 sample, float2 sensitivity)
{
    // 只需比较未解码获得真正法线
    half2 centerNormal = center.xy;
    float centerDepth = DecodeFloatRG(center.zw);
    half2 sampleNormal = sample.xy;
    float sampleDepth = DecodeFloatRG(sample.zw);

    // 获取法线差异值
    half2 diffNormal = abs(centerNormal - sampleNormal) * sensitivity.y;
    int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;

    // 获取深度差异值
    float diffDepth = abs(centerDepth - sampleDepth) * sensitivity.x;
    int isSameDepth = diffDepth < 0.1 * centerDepth;

    // 都为1时才返回1
    return isSameNormal * isSameDepth ? 1 : 0;
}

#endif