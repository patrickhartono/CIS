// Patch-Based Feature Extraction WITH VARIANCE
layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const int PATCH_SIZE = 16;

void main()
{
    ivec2 patchCoord = ivec2(gl_GlobalInvocationID.xy);
    ivec2 inputRes = ivec2(uTD2DInfos[0].res.zw);
    ivec2 gridSize = inputRes / PATCH_SIZE;
    
    if (patchCoord.x >= gridSize.x || patchCoord.y >= gridSize.y) {
        return;
    }
    
    ivec2 patchStart = patchCoord * PATCH_SIZE;
    
    // PASS 1: Calculate mean
    vec3 sumRGB = vec3(0.0);
    float sumLum = 0.0;
    
    for (int py = 0; py < PATCH_SIZE; ++py)
    {
        for (int px = 0; px < PATCH_SIZE; ++px)
        {
            ivec2 pixelPos = patchStart + ivec2(px, py);
            
            if (pixelPos.x < inputRes.x && pixelPos.y < inputRes.y)
            {
                vec3 rgb = texelFetch(sTD2DInputs[0], pixelPos, 0).rgb;
                sumRGB += rgb;
                sumLum += dot(rgb, vec3(0.2126, 0.7152, 0.0722));
            }
        }
    }
    
    float invN = 1.0 / float(PATCH_SIZE * PATCH_SIZE);
    vec3 meanRGB = sumRGB * invN;
    
    // PASS 2: Calculate variance (spread of colors)
    float variance = 0.0;
    
    for (int py = 0; py < PATCH_SIZE; ++py)
    {
        for (int px = 0; px < PATCH_SIZE; ++px)
        {
            ivec2 pixelPos = patchStart + ivec2(px, py);
            
            if (pixelPos.x < inputRes.x && pixelPos.y < inputRes.y)
            {
                vec3 rgb = texelFetch(sTD2DInputs[0], pixelPos, 0).rgb;
                vec3 diff = rgb - meanRGB;
                variance += dot(diff, diff);
            }
        }
    }
    
    variance *= invN;
    
    // Pack: RGB mean + variance (instead of luminance)
    vec4 feature = vec4(meanRGB, variance);
    
    imageStore(mTDComputeOutputs[0], patchCoord, TDOutputSwizzle(feature));
}