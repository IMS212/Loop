
#extension GL_EXT_gpu_shader4 : enable

//in vec3 at_velocity;   
// Compatibility
#extension GL_EXT_gpu_shader4 : enable
in vec3 vaPosition;
in vec4 vaColor;
in vec2 vaUV0;
in ivec2 vaUV2;
in vec3 vaNormal;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix = mat4(1.0);
uniform mat3 normalMatrix;
uniform vec3 chunkOffset;
out vec2 texcoord;
flat out float exposureA;
flat out float tempOffsets;
uniform sampler2D colortex4;
uniform int frameCounter;
#include "/lib/util.glsl"
void main() {

	tempOffsets = HaltonSeq2(frameCounter%10000);
	gl_Position = vec4(vec4(vaPosition + chunkOffset, 1.0).xy * 2.0 - 1.0, 0.0, 1.0);
	texcoord = vaUV0.xy;
	exposureA = texelFetch2D(colortex4,ivec2(10,37),0).r;
}
