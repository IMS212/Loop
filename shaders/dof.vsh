#extension GL_EXT_gpu_shader4 : enable

#define FinalR 1.0 //[0.0 0.025315 0.051271 0.077884 0.105170 0.133148 0.161834 0.191246 0.221402 0.252322 0.284025 0.316530 0.349858 0.384030 0.419067 0.454991 0.491824 0.529590 0.568312 0.608014 0.648721 0.690458 0.733253 0.777130 0.822118 0.868245 0.915540 0.964032 1.013752 1.064731 1.117000 1.170592 1.225540 1.281880 1.339646 1.398875 1.459603 1.521868 1.585709 1.651167 1.718281 1.787095 1.857651 1.929992 2.004166 2.080216 2.158192 2.238142 2.320116 2.404166 2.490342 2.578701 2.669296 2.762185 2.857425 2.955076 3.055199 3.157857 3.263114 3.371035 3.481689 3.595143 3.711470 3.830741 3.953032 4.078419 4.206979 4.338795 4.473947 4.612521 4.754602 4.900281 5.049647 5.202795 5.359819 5.520819 5.685894 5.855148 6.028687 6.206619 6.389056 6.576110 6.767901 6.964546 7.166169 7.372897 7.584858 7.802185 8.025013 8.253482 8.487735 8.727919 8.974182 9.226680 9.485569 9.751013 10.02317 10.30222 10.58834 10.88170 11.18249 ]
#define FinalG 1.0 //[0.0 0.025315 0.051271 0.077884 0.105170 0.133148 0.161834 0.191246 0.221402 0.252322 0.284025 0.316530 0.349858 0.384030 0.419067 0.454991 0.491824 0.529590 0.568312 0.608014 0.648721 0.690458 0.733253 0.777130 0.822118 0.868245 0.915540 0.964032 1.013752 1.064731 1.117000 1.170592 1.225540 1.281880 1.339646 1.398875 1.459603 1.521868 1.585709 1.651167 1.718281 1.787095 1.857651 1.929992 2.004166 2.080216 2.158192 2.238142 2.320116 2.404166 2.490342 2.578701 2.669296 2.762185 2.857425 2.955076 3.055199 3.157857 3.263114 3.371035 3.481689 3.595143 3.711470 3.830741 3.953032 4.078419 4.206979 4.338795 4.473947 4.612521 4.754602 4.900281 5.049647 5.202795 5.359819 5.520819 5.685894 5.855148 6.028687 6.206619 6.389056 6.576110 6.767901 6.964546 7.166169 7.372897 7.584858 7.802185 8.025013 8.253482 8.487735 8.727919 8.974182 9.226680 9.485569 9.751013 10.02317 10.30222 10.58834 10.88170 11.18249 ]
#define FinalB 1.0 //[0.0 0.025315 0.051271 0.077884 0.105170 0.133148 0.161834 0.191246 0.221402 0.252322 0.284025 0.316530 0.349858 0.384030 0.419067 0.454991 0.491824 0.529590 0.568312 0.608014 0.648721 0.690458 0.733253 0.777130 0.822118 0.868245 0.915540 0.964032 1.013752 1.064731 1.117000 1.170592 1.225540 1.281880 1.339646 1.398875 1.459603 1.521868 1.585709 1.651167 1.718281 1.787095 1.857651 1.929992 2.004166 2.080216 2.158192 2.238142 2.320116 2.404166 2.490342 2.578701 2.669296 2.762185 2.857425 2.955076 3.055199 3.157857 3.263114 3.371035 3.481689 3.595143 3.711470 3.830741 3.953032 4.078419 4.206979 4.338795 4.473947 4.612521 4.754602 4.900281 5.049647 5.202795 5.359819 5.520819 5.685894 5.855148 6.028687 6.206619 6.389056 6.576110 6.767901 6.964546 7.166169 7.372897 7.584858 7.802185 8.025013 8.253482 8.487735 8.727919 8.974182 9.226680 9.485569 9.751013 10.02317 10.30222 10.58834 10.88170 11.18249 ]
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
flat out vec4 exposure;
flat out vec2 rodExposureDepth;
uniform sampler2D colortex4;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

	gl_Position = (vec4(vec4(vaPosition + chunkOffset, 1.0).xy * 2.0 - 1.0, 0.0, 1.0));
	texcoord = vaUV0.xy;
	exposure=vec4(texelFetch2D(colortex4,ivec2(10,37),0).r*vec3(FinalR,FinalG,FinalB),texelFetch2D(colortex4,ivec2(10,37),0).r);
	rodExposureDepth = texelFetch2D(colortex4,ivec2(14,37),0).rg;
	rodExposureDepth.y = sqrt(rodExposureDepth.y/65000.0);
}
