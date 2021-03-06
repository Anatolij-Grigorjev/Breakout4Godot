shader_type canvas_item;

render_mode blend_mix;

uniform vec2 offset = vec2(8.0, 8.0);
uniform vec4 modulate : hint_color;
uniform float fade_rate = 2;

void vertex() {
	
	vec2 ps = vec2(0.5 / TEXTURE_PIXEL_SIZE.x, 0.5 / TEXTURE_PIXEL_SIZE.y);
	
	VERTEX *= 2.0;
	UV *= 2.0;
	VERTEX += ps;
}

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	
	vec4 col = texture(TEXTURE, UV);
	vec4 tail = vec4(modulate.rgb, texture(TEXTURE, UV - offset * ps).a * modulate.a);
	tail.a /= fade_rate;

	COLOR = mix( tail, col, col.a);
}