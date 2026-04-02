shader_type canvas_item;

// this is one of the shaders of all time

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec2 light_pos = vec2(0.5, 0.5); // normalized screen position (0-1)
uniform float exposure = 0.6;
uniform float decay = 0.95;
uniform float density = 0.8;
uniform float weight = 0.8;
uniform int samples = 64;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 delta = uv - light_pos;
    delta *= 1.0 / float(samples) * density;

    vec3 color = vec3(0.0);
    float illumination = 1.0;

    vec2 coord = uv;

    for (int i = 0; i < samples; i++) {
        coord -= delta;
        vec3 sample_tex = texture(SCREEN_TEXTURE, coord).rgb;

        sample_tex *= illumination * weight;
        color += sample_tex;

        illumination *= decay;
    }

    COLOR.rgb = color * exposure;
    COLOR.a = 1.0;
}