# **Concatenated Image Synthesis (CIS)**

![CIS](https://github.com/user-attachments/assets/34e055e6-55d8-4e1b-92c5-d6c7e11a257f)


_This is the pixel implementation of Concatenated Synthesis that commonly used for audio synthesis_

**How it works technically**

The system runs a 4-stage pipeline using GLSL compute shaders and a fragment shader:

- **Stage 1 – Corpus Preprocessing**  
  I extract features from 256 patches (64×64) from the corpus video. Each patch is analyzed for RGB mean and variance, stored as a 256×1 feature texture. This step runs offline using a compute shader.

- **Stage 2 – Input Feature Extraction**  
  The input video is divided into 16×16 patches (25×18 grid for a 400×300 input). A compute shader calculates the same features (RGB mean + variance) for each patch in real time.

- **Stage 3 – Nearest Neighbor Matching**  
  For every input patch, another compute shader loops through all 256 corpus features, computes the Euclidean distance, and finds the closest match. The best corpus patch ID is written into an index texture.

- **Stage 4 – Final Rendering**  
  A fragment shader reads the index texture, fetches the matching corpus patch from a 2D texture array, scales it from 64×64 to 16×16, and renders the final output at 400×300.


Everything runs on the GPU using GLSL Multi TOP for compute shaders and GLSL TOP for the final fragment-shader rendering.

**Tested Hardware**

This implementation is only tested on my MacBook Pro (64GB RAM, M-series Pro/Max tier – the highest configuration available at the time). Performance or behavior on other systems may differ.

I am not an expert in computer graphics, so if you have suggestions, critiques, improvements, or anything that could make this better, they are very welcome.

