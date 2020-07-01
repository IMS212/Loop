#version 120
#extension GL_EXT_gpu_shader4 : enable


#include "/lib/settings.glsl"


//Computes volumetric clouds at variable resolution (default 1/4 res)



flat varying vec3 sunColor;
flat varying vec3 moonColor;
flat varying vec3 avgAmbient;
flat varying float tempOffsets;

uniform sampler2D depthtex0;
uniform sampler2D noisetex;

uniform vec3 sunVec;
uniform vec2 texelSize;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform int frameCounter;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

vec3 toScreenSpace(vec3 p) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}


#include "/lib/volumetricClouds.glsl"


float interleaved_gradientNoise(){
	vec2 coord = gl_FragCoord.xy;
	float noise = fract(52.9829189*fract(0.06711056*coord.x + 0.00583715*coord.y)+frameCounter/1.6180339887);
	return noise;
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
/* DRAWBUFFERS:0 */
	#ifdef VOLUMETRIC_CLOUDS
	vec2 halfResTC = vec2(floor(gl_FragCoord.xy)/CLOUDS_QUALITY+0.5);
	bool doClouds = false;
	for (int i = 0; i < floor(1.0/CLOUDS_QUALITY)+1.0; i++){
		for (int j = 0; j < floor(1.0/CLOUDS_QUALITY)+1.0; j++){
			if (texelFetch2D(depthtex0,ivec2(halfResTC) + ivec2(i, j), 0).x >= 1.0)
				doClouds = true;
		}
	}
	if (doClouds){
		vec3 fragpos = toScreenSpace(vec3(halfResTC*texelSize,1.0));
		vec4 currentClouds = renderClouds(fragpos,vec3(0.),interleaved_gradientNoise(),sunColor/150.,moonColor/150.,avgAmbient/150.);
		gl_FragData[0] = currentClouds;
	}
	else
		gl_FragData[0] = vec4(0.0,0.0,0.0,1.0);									 

	#else
		gl_FragData[0] = vec4(0.0,0.0,0.0,1.0);
	#endif

}
