// Corpus Feature Extraction WITH VARIANCE
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

const int PATCH_SIZE = 16;  // Adjust if your corpus patches are different size

void main()
{
    int slice = int(gl_GlobalInvocationID.x);
    int totalSlices = int(uTD2DArrayInfos[0].depth.y);
    
    if (slice >= totalSlices)
        return;
    
    int w = int(uTD2DArrayInfos[0].res.z);
    int h = int(uTD2DArrayInfos[0].res.w);
    
    if (w == 0 || h == 0)
        return;
    
    int totalPixels = w * h;
    
    // PASS 1: Calculate mean
    vec3 sumRGB = vec3(0.0);
    
    for (int y = 0; y < h; y++)
    for (int x = 0; x < w; x++)
    {
        vec3 rgb = texelFetch(sTD2DArrayInputs[0], ivec3(x, y, slice), 0).rgb;
        sumRGB += rgb;
    }
    
    float invN = 1.0 / float(totalPixels);
    vec3 meanRGB = sumRGB * invN;
    
    // PASS 2: Calculate variance
    float variance = 0.0;
    
    for (int y = 0; y < h; y++)
    for (int x = 0; x < w; x++)
    {
        vec3 rgb = texelFetch(sTD2DArrayInputs[0], ivec3(x, y, slice), 0).rgb;
        vec3 diff = rgb - meanRGB;
        variance += dot(diff, diff);
    }
    
    variance *= invN;
    
    // Pack: RGB mean + variance
    vec4 feature = vec4(meanRGB, variance);
    
    imageStore(mTDComputeOutputs[0], ivec2(slice, 0), TDOutputSwizzle(feature));
}