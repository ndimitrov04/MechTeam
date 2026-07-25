shader_type canvas_item;

uniform int iterations = 17;
uniform float formuparam = 0.53;

uniform int volsteps = 10;
uniform float stepsize = 0.1;

uniform float zoom   = 0.800;
uniform float tile   = 0.850;
uniform float speed  = 0.001;

uniform float brightness = 0.0015;
uniform float darkmatter = 0.300;
uniform float distfading = 0.730;
uniform float saturation = 0.850;

uniform vec2 rotation;
uniform sampler2D coloramp;
uniform float colorampMix = .5;
uniform bool isColoramp;

uniform float pixel_size = 8.0; // bigger = more pixelated

void fragment()
{
	vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
	float iTime = TIME;

	// pixelate screen coords
	vec2 fragCoord = floor(FRAGCOORD.xy / pixel_size) * pixel_size;

	// get coords and direction
	vec2 uv = fragCoord / iResolution.xy - .5;
	uv.y *= iResolution.y / iResolution.x;
	vec3 dir = vec3(uv * zoom, 1.);
	float time = iTime * speed + .25;

	// mouse rotation
	float a1 = .5 + rotation.x / iResolution.x * 2.;
	float a2 = .8 + rotation.y / iResolution.y * 2.;
	mat2 rot1 = mat2(vec2(cos(a1), sin(a1)), vec2(-sin(a1), cos(a1)));
	mat2 rot2 = mat2(vec2(cos(a2), sin(a2)), vec2(-sin(a2), cos(a2)));
	dir.xz *= rot1;
	dir.xy *= rot2;
	vec3 from = vec3(1., .5, 0.5);
	from += vec3(time * 2., time, -2.);
	from.xz *= rot1;
	from.xy *= rot2;

	float s = 0.1, fade = 1.;
	vec3 v = vec3(0.);
	for (int r = 0; r < volsteps; r++) {
		vec3 p = from + s * dir * .5;
		p = abs(vec3(tile) - mod(p, vec3(tile * 2.)));
		float pa, a = pa = 0.;
		for (int i = 0; i < iterations; i++) {
			p = abs(p) / dot(p, p) - formuparam;
			a += abs(length(p) - pa);
			pa = length(p);
		}
		float dm = max(0., darkmatter - a * a * .001);
		a *= a * a;
		if (r > 6) fade *= 1. - dm;
		v += fade;
		v += vec3(s, s * s, s * s * s * s) * a * brightness * fade;
		fade *= distfading;
		s += stepsize;
	}
	v = mix(vec3(length(v)), v, saturation);

	COLOR = vec4(v * .01, 1.);

	if (isColoramp) {
		COLOR += texture(coloramp, vec2(v.r * .01, 0.)) * colorampMix;
	}
}
