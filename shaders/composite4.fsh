#version 330 compatibility
#include "lib/util.glsl"

uniform sampler2D colortex6;
uniform sampler2D colortex7;

in vec2 texcoord;

/*RENDERTARGETS: 7*/
layout(location = 0) out vec4 outGaussianImage;

void main() {
    vec3 scene = texture(colortex6, texcoord).rgb;
    vec2 texOffset = 1.0 / textureSize(colortex6, 0); // gets size of single texel
    vec3 result = scene * gaussianWeights[0];
    
    for(int i = 1; i < GAUSSIAN_KERNEL_SIZE; i++) {
        result += texture(colortex6, texcoord + vec2(0.0, texOffset.y * i * GAUSIAN_KERNEL_STRIDE)).rgb * gaussianWeights[i];
        result += texture(colortex6, texcoord - vec2(0.0, texOffset.y * i * GAUSIAN_KERNEL_STRIDE)).rgb * gaussianWeights[i];
    }
    
    outGaussianImage = vec4(result, 1.0);

}