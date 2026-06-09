shader_type canvas_item;
uniform float speed = 0.10;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 3.0);

void fragment() {
    vec2 uv = UV;
    uv.x = mod(uv.x + TIME * speed, 1.00);
    COLOR = texture(TEXTURE, uv);
	COLOR.rgb *= tint.rgb;
}