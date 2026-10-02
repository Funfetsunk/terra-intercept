shader_type canvas_item;

// Ice-fog banks drawn as an ordered dither in two palette greys, so the fog
// stays crisp and on-palette. Each bank is (top_y, bottom_y, density, feather)
// in the rect's local pixels; FogBanks fills them in every frame.

uniform vec4 banks[4];
uniform int bank_count = 0;
uniform vec2 rect_size = vec2(360.0, 360.0);
uniform vec4 fog_light : source_color = vec4(0.780, 0.863, 0.816, 1.0);
uniform vec4 fog_dark : source_color = vec4(0.608, 0.671, 0.698, 1.0);
// Gentle drifting wisps so banks don't read as flat bars.
uniform float wisp_strength = 0.45;
uniform float wisp_scale = 0.045;
uniform float wisp_speed = 0.6;

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

void fragment() {
	vec2 local = floor(UV * rect_size);
	float density = 0.0;
	for (int i = 0; i < 4; i++) {
		if (i >= bank_count) break;
		vec4 b = banks[i];
		float edge = smoothstep(b.x, b.x + b.w, local.y) * (1.0 - smoothstep(b.y - b.w, b.y, local.y));
		density = max(density, b.z * edge);
	}
	float wisp = sin(local.x * wisp_scale + local.y * wisp_scale * 0.7 + TIME * wisp_speed)
		* sin(local.x * wisp_scale * 0.5 - TIME * wisp_speed * 0.7);
	density = clamp(density * (1.0 - wisp_strength + wisp_strength * wisp), 0.0, 1.0);
	ivec2 cell = ivec2(mod(floor(FRAGCOORD.xy), 4.0));
	float threshold = (BAYER[cell.y * 4 + cell.x] + 0.5) / 16.0;
	if (threshold > density) {
		discard;
	}
	COLOR = threshold < density * 0.5 ? fog_light : fog_dark;
}
