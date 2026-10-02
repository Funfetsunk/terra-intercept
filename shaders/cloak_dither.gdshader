shader_type canvas_item;

// Cloaker shimmer: keeps only a dithered fraction of the sprite's pixels,
// chosen by a 4x4 ordered-dither threshold, so a cloaked enemy shows as a
// faint sparkle and decloaks in clean steps. No blending, no off-palette colours.

uniform float visibility : hint_range(0.0, 1.0) = 1.0;

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	ivec2 cell = ivec2(mod(floor(FRAGCOORD.xy), 4.0));
	float threshold = (BAYER[cell.y * 4 + cell.x] + 0.5) / 16.0;
	if (threshold > visibility || c.a < 0.5) {
		discard;
	}
	COLOR = c;
}
