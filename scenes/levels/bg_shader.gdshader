shader_type canvas_item;
// ========================================
// Background Blur + Subtle Distortion
// Tuned for 320x180 (low-res) — keeps motion gentle.
// Attach to: ColorRect / Sprite2D / TextureRect
// ========================================

// --- Blur settings ---
uniform float blur_amount : hint_range(0.0, 10.0) = 3.0;
uniform int blur_samples : hint_range(1, 16) = 8;

// --- Distortion settings ---
// How far UVs get pushed around, in UV space (0..1).
// 0.004 ≈ ~1.3 px at 320 width — very subtle.
uniform float distort_strength : hint_range(0.0, 0.05) = 0.004;
// Wave frequency — higher = more ripples across the image.
uniform vec2 distort_frequency = vec2(4.0, 3.0);
// Animation speed.
uniform float distort_speed : hint_range(0.0, 3.0) = 0.4;

// Optional screen texture (use BackBufferCopy node if blurring what's behind)
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

// Gaussian-like box blur
vec4 blur(sampler2D tex, vec2 uv, vec2 pixel_size, float amount, int samples) {
	vec4 color = vec4(0.0);
	float total = 0.0;
	float step_size = amount / float(samples);
	for (int x = -samples; x <= samples; x++) {
		for (int y = -samples; y <= samples; y++) {
			vec2 offset = vec2(float(x), float(y)) * pixel_size * step_size;
			float weight = 1.0 - (length(vec2(float(x), float(y))) / float(samples));
			weight = max(weight, 0.0);
			color += texture(tex, uv + offset) * weight;
			total += weight;
		}
	}
	return color / total;
}

void fragment() {
	// 1. Subtle animated UV distortion (two sine waves, perpendicular axes)
	float t = TIME * distort_speed;
	vec2 offset = vec2(
		sin(UV.y * distort_frequency.x + t),
		cos(UV.x * distort_frequency.y + t * 0.8)
	) * distort_strength;

	vec2 distorted_uv = UV + offset;

	// 2. Blurred background sampled at distorted UV
	vec4 blurred = blur(TEXTURE, distorted_uv, TEXTURE_PIXEL_SIZE, blur_amount, blur_samples);

	COLOR = blurred;
}
