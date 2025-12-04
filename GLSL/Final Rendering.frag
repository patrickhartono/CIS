// Fragment Shader - Concatenated Synthesis Renderer
out vec4 fragColor;

const int PATCH_SIZE = 16;

void main()
{
    // Get current pixel position in output
    ivec2 pixelPos = ivec2(gl_FragCoord.xy);
    
    // Calculate which patch this pixel belongs to
    ivec2 patchCoord = pixelPos / PATCH_SIZE;
    
    // Position within patch (0-15)
    ivec2 posInPatch = pixelPos % PATCH_SIZE;
    
    // Read corpus patch ID from index texture (glslmulti4)
    vec4 indexData = texelFetch(sTD2DInputs[0], patchCoord, 0);
    float normalizedID = indexData.r;
    
    // Denormalize to get corpus slice ID
    int corpusSliceID = int(normalizedID * 255.0 + 0.5);
    corpusSliceID = clamp(corpusSliceID, 0, 255);
    
    // CRITICAL FIX: Corpus patches are 64x64, not 16x16!
    // Scale position from 0-15 to 0-63
    ivec2 corpusPixelPos = (posInPatch * 64) / PATCH_SIZE;  // Scale up 4x (64/16 = 4)
    
    // Fetch pixel from corpus texture array
    vec3 color = texelFetch(sTD2DArrayInputs[0], ivec3(corpusPixelPos.x, corpusPixelPos.y, corpusSliceID), 0).rgb;
    
    fragColor = TDOutputSwizzle(vec4(color, 1.0));
}