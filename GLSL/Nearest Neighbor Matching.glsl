// Nearest Neighbor Matching
// For each input patch, find the closest corpus patch

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Hardcoded corpus size (256 patches from tex3d1)
const int CORPUS_SIZE = 256;

void main()
{
    // Get input patch coordinate
    ivec2 inputPatchCoord = ivec2(gl_GlobalInvocationID.xy);
    
    // Get output resolution (should be 25x18)
    ivec2 outputRes = ivec2(uTDOutputInfo.res.zw);
    
    // Early exit if outside bounds
    if (inputPatchCoord.x >= outputRes.x || inputPatchCoord.y >= outputRes.y) {
        return;
    }
    
    // Read input patch feature from glslmulti3 output
    vec4 inputFeature = texelFetch(sTD2DInputs[0], inputPatchCoord, 0);
    
    // Initialize best match tracking
    float minDistance = 1e10;  // Very large number
    int bestCorpusID = 0;
    
    // Loop through all corpus patches
    for (int corpusID = 0; corpusID < CORPUS_SIZE; corpusID++)
    {
        // Read corpus feature from glslmulti1 output (stored as 256x1 texture)
        vec4 corpusFeature = texelFetch(sTD2DInputs[1], ivec2(corpusID, 0), 0);
        
        // IMPROVED: Calculate weighted distance - RGB only, ignore luminance
        vec3 rgbDiff = inputFeature.rgb - corpusFeature.rgb;
        float distance = dot(rgbDiff, rgbDiff);  // Squared RGB distance only
        
        // Update best match if this is closer
        if (distance < minDistance) {
            minDistance = distance;
            bestCorpusID = corpusID;
        }
    }
    
    // Output: store the best corpus patch ID
    // Normalize ID to 0-1 range for texture storage
    float normalizedID = float(bestCorpusID) / float(CORPUS_SIZE - 1);
    
    // Store as grayscale (R channel = patch ID)
    vec4 outputColor = vec4(normalizedID, 0.0, 0.0, 1.0);
    
    imageStore(mTDComputeOutputs[0], inputPatchCoord, TDOutputSwizzle(outputColor));
}