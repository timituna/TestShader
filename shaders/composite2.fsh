#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform float frameTime;

in vec2 texcoord;

const int SAMPLE_COUNT = 15;
const float ADAPTATION_SPEED = 1.5;

/* RENDERTARGETS: 4 */
layout(location = 0) out vec4 outExposure;

float getLuminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    float totalLuminance = 0.0;
    //int count = 0;
    float totalWeight = 0.0;

    float stepX = 1.0 / float(SAMPLE_COUNT);
    float stepY = 1.0 / float(SAMPLE_COUNT);

    vec2 centerPixel = vec2(0.5, 0.5);

    if(distance(texcoord, centerPixel) > 0.01) {
        outExposure = vec4(0.0);
        return;
    }

    for(float x = 0.0; x < 1.0; x += stepX) {
        for(float y = 0.0; y < 1.0; y += stepY) {
            vec2 coords = vec2(x, y);
            vec3 color = texture(colortex0, coords).rgb;
            float luminance = getLuminance(color);
            luminance = min(luminance, 15.0);
            float distanceToCenter = distance(coords, vec2(0.5, 0.75)); // slightly above center
            float weight = 1.0 - smoothstep(0.0, 0.7071, distanceToCenter); // 0.7071 is approx sqrt(2)/2
            weight = max(weight, 0.1); // ensure a minimum weight
            totalLuminance += luminance * weight;
            totalWeight += weight;
            //count++;
        }
    }

    float avgLuminance = totalLuminance / totalWeight;
    avgLuminance = clamp(avgLuminance, 0.5, 1000.0);
    float targetExposure = 0.15 / avgLuminance;
    float oldExposure = texture(colortex4, vec2(0.5, 0.5)).r;
    
    if(oldExposure <= 0.0001) {
        oldExposure = targetExposure;
    }

    float smoothExposure = oldExposure + (targetExposure - oldExposure) * ADAPTATION_SPEED * frameTime;
    outExposure = vec4(smoothExposure, 0.0, 0.0, 1.0);
}