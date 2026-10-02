shader_type canvas_item;

// Screen fade that stays on the palette: each game pixel is either fully the
// fade colour or untouched, chosen by a 4x4 ordered-dither (Bayer) threshold,
// so the screen dissolves in a crisp pattern instead of a translucent blend.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fade_color : source_color = vec4(0.180, 0.133, 0.184, 1.0);

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

void fragment() {
	ivec2 cell = ivec2(mod(floor(FRAGCOORD.xy), 4.0));
	float threshold = (BAYER[cell.y * 4 + cell.x] + 0.5) / 16.0;
	if (threshold > progress) {
		discard;
	}
	COLOR = fade_color;
}
