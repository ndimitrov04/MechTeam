shader_type canvas_item;
render_mode blend_add;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec2 light_pos = vec2(0.5, 0.3);

uniform float exposure = 0.7;
uniform float decay = 0.96;
uniform float density = 0.9;
uniform float weight = 0.6;
uniform int samples = 64;

uniform float threshold = 0.7; // brightness cutoff

float luminance(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

float local_brightness(vec2 uv) {
    float sum = 0.0;
    float count = 0.0;

    float offset = 0.002; // tweak based on resolution

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 o = vec2(float(x), float(y)) * offset;
            vec3 col = texture(SCREEN_TEXTURE, uv + o).rgb;
            sum += luminance(col);
            count += 1.0;
        }
    }

    return sum / count;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 delta = (uv - light_pos) * density / float(samples);

    vec3 color = vec3(0.0);
    float illumination = 1.0;
    vec2 coord = uv;

    for (int i = 0; i < samples; i++) {
        coord -= delta;

        vec3 sample_col = texture(SCREEN_TEXTURE, coord).rgb;

        // only keep bright areas
        float lum = local_brightness(coord);
        float mask = smoothstep(threshold, 1.0, lum);
        sample_col *= mask;

        sample_col *= illumination * weight;
        color += sample_col;

        illumination *= decay;
    }

    COLOR.rgb = color * exposure;
    COLOR.a = 1.0;
}