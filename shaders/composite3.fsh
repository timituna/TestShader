#version 330 compatibility
#include "lib/util.glsl"

uniform sampler2D colortex0;

in vec2 texcoord;

vec3 thresholdColor(vec2 uv) {
    vec3 scene = texture(colortex0, uv).rgb;
    float brightness = dot(scene, vec3(0.2126, 0.7152, 0.0722)); // turn to greyscale
    float knee = 1.0;
    float softBrightness = brightness - GAUSSIAN_BRIGHTNESS_THRESHOLD + knee;
    softBrightness = clamp(softBrightness, 0.0, 2 * knee);
    softBrightness = softBrightness * softBrightness / (4.0 * knee + 0.0001);
    float contribution = max(softBrightness, brightness - GAUSSIAN_BRIGHTNESS_THRESHOLD);
    contribution = max(contribution, 0.0);

    if(brightness > 0.001) {
        return scene * contribution / brightness;
    } else {
        return vec3(0.0);
    }

}

/*RENDERTARGETS: 6*/
layout(location = 0) out vec4 outGaussianHorizontal;

void main() {
    vec2 texOffset = 1.0 / textureSize(colortex0, 0); // gets size of single texel
    vec3 result = thresholdColor(texcoord) * gaussianWeights[0];

    for(int i = 1; i < GAUSSIAN_KERNEL_SIZE; i++) {
        vec2 offset = vec2(texOffset.x * i * GAUSIAN_KERNEL_STRIDE, 0.0);
        result += thresholdColor(texcoord + offset) * gaussianWeights[i];
        result += thresholdColor(texcoord - offset) * gaussianWeights[i];
    }

    outGaussianHorizontal = vec4(result, 1.0);
}