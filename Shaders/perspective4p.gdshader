shader_type canvas_item;

uniform vec2 top_left     = vec2(0.0, 0.0);
uniform vec2 top_right    = vec2(0.0, 0.0);
uniform vec2 bottom_left  = vec2(0.0, 0.0);
uniform vec2 bottom_right = vec2(0.0, 0.0);

void vertex() {
    vec2 offset;

    if (UV.x < 0.5) {
        offset = mix(
            bottom_left,
            top_left,
            UV.y
        );
    } else {
        offset = mix(
            bottom_right,
            top_right,
            UV.y
        );
    }

    VERTEX += offset;
}

void fragment() {
    COLOR = texture(TEXTURE, UV);
}
