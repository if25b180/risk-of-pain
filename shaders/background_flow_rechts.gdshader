shader_type canvas_item;
uniform float speed = 0.30;

void fragment() {
    vec2 uv = UV;
    uv.x = mod(uv.x - TIME * speed, 1.00);
    COLOR = texture(TEXTURE, uv);
}