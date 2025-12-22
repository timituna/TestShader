/*
const int colortex0Format = RGBA16F;
*/
/*
const int colortex1Format = RGBA16F;
*/
/*
const int colortex2Format = RGBA16F;
*/
/*
const int colortex4Format = R32F;
*/
/*
const bool colortex4Clear = false;
*/

#define GAMMA 2.2
#define DAY_BEGINNING 23215
#define NIGHT_BEGINNING 12785
#define DAY_DURATION 13569
#define NIGHT_DURATION 10431
#define DAYSKY_COLOR vec3(0.95, 0.84, 0.35)
#define NIGHTSKY_COLOR vec3(0.005, 0.005, 0.02)
#define PI 3.14159265384

const int shadowMapResolution = 2048; // [512 1024 2048 4096]


vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

bool isDayTime(float time){
	return (time >= 0.0 && time < DAY_DURATION);
}

float dayNightCurve(float time){
	if(isDayTime(time))
		return sin(PI * (time - 0.0) / DAY_DURATION);
	else 
		return sin(PI + (PI * (time - DAY_DURATION) / NIGHT_DURATION));
}

float normalizeWorldTime(int time) {
	float normalizedTime;

	if(time >= DAY_BEGINNING && time < 24000) {
		normalizedTime = time - DAY_BEGINNING;
	}
	else {
		normalizedTime = time + (24000 - DAY_BEGINNING);
	}
	return normalizedTime; //not exactly normalized since value is not between 0 and 1
}
