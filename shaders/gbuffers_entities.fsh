#version 120
#extension GL_EXT_gpu_shader4 : enable
#extension GL_ARB_shader_texture_lod : enable
#include "/lib/res_params.glsl"
#ifdef SPEC
uniform sampler2D specular;
#endif
uniform int framemod8;
uniform sampler2D normals;
uniform int entityId;
varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 normalMat;
uniform vec2 texelSize;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

vec3 worldToView(vec3 worldPos) {

    vec4 pos = vec4(worldPos, 0.0);
    pos = gbufferModelView * pos;

    return pos.xyz;
}

vec3 viewToWorld(vec3 viewPos) {

    vec4 pos;
    pos.xyz = viewPos;
    pos.w = 0.0;
    pos = gbufferModelViewInverse * pos;

    return pos.xyz;
}
uniform sampler2D texture;
uniform float frameTimeCounter;
uniform mat4 gbufferProjectionInverse;
uniform vec4 entityColor;
float interleaved_gradientNoise(){
	return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y)+frameTimeCounter*51.9521);
}

//encode normal in two channels (xy),torch(z) and sky lightmap (w)
vec4 encode (vec3 unenc, vec2 lightmaps)
{
	unenc.xy = unenc.xy / dot(abs(unenc), vec3(1.0)) + 0.00390625;
	unenc.xy = unenc.z <= 0.0 ? (1.0 - abs(unenc.yx)) * sign(unenc.xy) : unenc.xy;
    vec2 encn = unenc.xy * 0.5 + 0.5;
	
    return vec4((encn),vec2(lightmaps.x,lightmaps.y));
}
mat3 cotangent( vec3 N, vec3 p, vec2 uv )
{

    vec3 dp1 = dFdx( p );
    vec3 dp2 = dFdy( p );
    vec2 duv1 = dFdx( uv );
    vec2 duv2 = dFdy( uv );
 
    vec3 dp2perp = cross( dp2, N );
    vec3 dp1perp = cross( N, dp1 );
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
 

    float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
    return mat3( T * invmax, B * invmax, N );
}



//encoding by jodie
float encodeVec2(vec2 a){
    const vec2 constant1 = vec2( 1., 256.) / 65535.;
    vec2 temp = floor( a * 255. );
	return temp.x*constant1.x+temp.y*constant1.y;
}
float encodeVec2(float x,float y){
    return encodeVec2(vec2(x,y));
}

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec3 toScreenSpace(vec3 p) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}
float luma(vec3 color) {
	return dot(color,vec3(0.299, 0.587, 0.114));
}
		const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
									vec2(-1.,3.)/8.,
									vec2(5.0,1.)/8.,
									vec2(-3,-5.)/8.,
									vec2(-5.,5.)/8.,
									vec2(-7.,-1.)/8.,
									vec2(3,7.)/8.,
									vec2(7.,-7.)/8.);
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
/* DRAWBUFFERS:17A2 */
void main() {
	float lightningBolt = float(entityId == 58);
	vec2 lm = lmtexcoord.zw;
		vec2 tempOffset=offsets[framemod8];	
		vec3 fragpos = toScreenSpace(gl_FragCoord.xyz*vec3(texelSize/RENDER_SCALE,1.0)-vec3(vec2(tempOffset)*texelSize*0.5,0.0));		
	#ifdef SPEC	
		float labemissive = texture2D(specular, lmtexcoord.xy, -400).a;

		float emissive = float(labemissive > 1.98 && labemissive < 2.02) * 0.25;
		float emissive2 = mix(labemissive < 1.0 ? labemissive : 0.0, 1.0, emissive);

	
	  	gl_FragData[2].a = clamp(clamp(emissive2,0.0,1.0),0,1);
	#endif	
	float noise = interleaved_gradientNoise();
	vec3 normal = normalMat.xyz;

	vec4 data0 = texture2D(texture, lmtexcoord.xy)*color;
	float avgBlockLum = luma(texture2DLod(texture, lmtexcoord.xy,128).rgb*color.rgb);
  data0.rgb = clamp(data0.rgb*pow(avgBlockLum,-0.33)*0.85,0.0,1.0);
	data0.rgb = mix(data0.rgb,entityColor.rgb,entityColor.a);
	if (data0.a > 0.3) data0.a = normalMat.a;
	else data0.a = 0.0;
	
	
//	based on code from Christian Schüler
	vec3 normalTex = texture2D(normals, lmtexcoord.xy , 0).rgb;
	lm *= normalTex.b;
    normalTex = normalTex * 255./127. - 128./127.;
	
    normalTex.z = sqrt( 1.0 - dot( normalTex.xy, normalTex.xy ) );
    normalTex.y = -normalTex.y;
    normalTex.x = -normalTex.x;

    mat3 TBN = cotangent( normal, -fragpos, lmtexcoord.xy );
    normal = normalize( TBN * clamp(normalTex,-1,1) );	
	
	vec4 data1 = clamp(noise/256.+encode(viewToWorld(normal), lm),0.,1.0);
	if (lightningBolt > 0.5) data0.rgb = vec3(1.0), data0.a = 0.5;	

	if (lightningBolt > 0.5) gl_FragData[3] = vec4(1.0);
	gl_FragData[0] = vec4(encodeVec2(data0.x,data1.x),encodeVec2(data0.y,data1.y),encodeVec2(data0.z,data1.z),encodeVec2(data1.w,data0.w));
	#ifdef SPEC
		gl_FragData[1] = vec4(texture2DLod(specular, lmtexcoord.xy, 0).rgb,0);
	#else	
		gl_FragData[1] = vec4(0.0);
	#endif	
	gl_FragData[2].rgb = normal;

}
