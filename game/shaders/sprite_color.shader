shader_type canvas_item;

uniform vec4 modulate : hint_color;
uniform float mix_coef: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, modulate.rgb, mix_coef);
	COLOR = color;
}