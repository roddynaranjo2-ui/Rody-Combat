shader_type canvas_item;

uniform vec4 color_top    : source_color = vec4(0.45, 0.78, 0.95, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.15, 0.45, 0.85, 1.0);
uniform float blur_amount : hint_range(0.0, 0.05) = 0.02;
uniform float wave_amount : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	float wave = (sin(UV.x * 3.14159 * wave_amount) - 0.5) * blur_amount;
	float t = UV.y + wave;
	COLOR = mix(color_top, color_bottom, smoothstep(0.0, 1.0, t));
}
