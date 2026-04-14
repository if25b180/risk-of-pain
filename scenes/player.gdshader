shader_type canvas_item;

uniform float speed = 2.0;
uniform float strength = 0.02;

void fragment() {
    float t = TIME * speed;
    float breathe = sin(t) * strength;

    vec4 tex = texture(TEXTURE, UV);
    tex.rgb += breathe;

    COLOR = tex;
}
