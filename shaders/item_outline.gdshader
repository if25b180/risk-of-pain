shader_type canvas_item;
uniform vec4 flat_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float alpha = texture(TEXTURE, UV).a;
    COLOR = vec4(flat_color.rgb, flat_color.a * alpha);
}