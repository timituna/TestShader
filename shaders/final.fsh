#version 330 compatibility
#include "/lib/util.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;

in vec2 texcoord;

const mat3 acesInputMat = mat3(
	vec3(0.59719, 0.35458, 0.04823),
	vec3(0.07600, 0.90834, 0.01566),
	vec3(0.02840, 0.13383, 0.83777)
);

const mat3 acesOutputMat = mat3(
	vec3( 1.60475, -0.53108, -0.07367),
	vec3(-0.10208,  1.10813, -0.00605),
	vec3(-0.00327, -0.07276,  1.07602)
);

vec3 acesMultiply(const mat3 m, vec3 v){
	float x = m[0].x * v.x + m[0].y * v.y + m[0].z * v.z;
	float y = m[1].x * v.x + m[1].y * v.y + m[1].z * v.z;
	float z = m[2].x * v.x + m[2].y * v.y + m[2].z * v.z;
	return vec3(x, y, z);
}

vec3 rttOdtFit(vec3 v)
{
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return a / b;
}

vec3 acesFitted(vec3 v)
{
    v = acesMultiply(acesInputMat, v);
    v = rttOdtFit(v);
    return acesMultiply(acesOutputMat, v);
}

vec3 acesNarkowicz(vec3 v)
{
	v *= 0.6; 
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((v * (a * v + b)) / (v * (c * v + d) + e), 0.0, 1.0);
}

const float A = 0.2;
const float B = 0.40;
const float C = 0.10;
const float D = 0.60;
const float E = 0.022;
const float F = 0.30;
const float W = 9.8;

vec3 uncharted2Tonemap(vec3 x) {
	return (( x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

float Uncharted2Tonemap(float x) {
	return (( x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

float autoExposure() {
	vec3 centerColor = texture(colortex0, vec2(0.5, 0.5)).rgb;
	float centerLuminance = dot(centerColor, vec3(0.2126, 0.7152, 0.0722));
	float clampedLuminance = clamp(centerLuminance, 0.1, 40.0);
	return 0.5 / clampedLuminance;
}

//const float exposure = 0.05;
//const float desaturationFactor = 0.01;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	vec3 bloom = texture(colortex7, texcoord).rgb;
	float exposure = texture(colortex4, vec2(0.5)).r;
	float depth = texture(depthtex0, texcoord).r;
	
	if (depth != 1.0) {
		color.rgb *= exposure;
/*		if(color.r > 10.0)
			color.r *= desaturationFactor;
		if(color.g > 10.0)
			color.g *= desaturationFactor;
		if(color.b > 10.0)
			color.b *= desaturationFactor;
*/		
		#ifdef BLOOM
			bloom *= exposure;
			color.rgb += bloom * BLOOM_STRENGTH; // add bloom
		#endif
		color.rgb = acesNarkowicz(color.rgb);
		//color.rgb = uncharted2Tonemap(color.rgb * 8.0);
		//color.rgb /= Uncharted2Tonemap(W);
	}
	


		// Debug: Show me where the values are exploding
	/*if(color.r > 1.0 || color.g > 1.0 || color.b > 1.0) {
		// Show HDR pixels as BRIGHT RED
		color.rgb = vec3(1.0, 0.0, 0.0); 
	} else {
		// Show LDR pixels as GRAY
		color.rgb = vec3(0.1);
	}*/

	color.rgb = pow(color.rgb, vec3(1.0 / GAMMA)); // gamma correction

	#ifdef DEBUG_BLOOM
        // OVERRIDE everything and just show me the bloom buffer
        vec3 debugBloom = texture(colortex7, texcoord).rgb;
        
        // Apply a little gamma so we can see faint details
        color = vec4(pow(debugBloom, vec3(1.0/2.2)), 1.0);
        return; 
    #endif
}