shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV;

    vec3 col = texture(SCREEN_TEXTURE, uv).rgb;

    // grayscale
    float gray = dot(col, vec3(0.299, 0.587, 0.114));

    // softer Game Boy palette
    vec3 c1 = vec3(0.10, 0.16, 0.10);
    vec3 c2 = vec3(0.24, 0.35, 0.18);
    vec3 c3 = vec3(0.50, 0.62, 0.30);
    vec3 c4 = vec3(0.78, 0.84, 0.52);

    vec3 final_col;

    if (gray < 0.25) {
        final_col = c1;
    } else if (gray < 0.5) {
        final_col = c2;
    } else if (gray < 0.75) {
        final_col = c3;
    } else {
        final_col = c4;
    }

    // VERY subtle LCD lines
    float line = sin(uv.y * 700.0) * 0.01;
    final_col -= line;

    COLOR = vec4(final_col, 1.0);
}