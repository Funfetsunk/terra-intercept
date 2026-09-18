shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.25;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	float scanline = sin(SCREEN_UV.y * 360.0) * 0.5 + 0.5;
	color.rgb *= mix(1.0, scanline, scanline_strength);
	vec2 centered = SCREEN_UV - vec2(0.5);
	float vignette = 1.0 - dot(centered, centered) * vignette_strength;
	color.rgb *= vignette;
	COLOR = color;
}
