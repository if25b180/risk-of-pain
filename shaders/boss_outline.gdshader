shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 0.5);
uniform float outline_width : hint_range(0, 10) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec2 size = TEXTURE_PIXEL_SIZE * outline_width;

    // Nachbarpixel abtasten (4 Kanten + 4 Diagonalen)
    float outline = 0.0;
    outline += texture(TEXTURE, UV + vec2( size.x,  0.0)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x,  0.0)).a;
    outline += texture(TEXTURE, UV + vec2( 0.0,  size.y)).a;
    outline += texture(TEXTURE, UV + vec2( 0.0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2( size.x,  size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x,  size.y)).a;
    outline += texture(TEXTURE, UV + vec2( size.x, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    outline = min(outline, 1.0);

    // Outline nur dort zeichnen, wo das Sprite selbst transparent ist
    COLOR = mix(color, outline_color, outline - color.a);
}