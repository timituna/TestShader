#version 330 compatibility

uniform mat4 gbufferModelViewInverse;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
	//Vertex position
	gl_Position = ftransform();

	//Out variables
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	lmcoord / (30.0 / 32.0) - (1.0 / 32.0);
	normal = mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal; // this transforms the normal from model to world space
	
	//Biome Tint
	glcolor = gl_Color;
}