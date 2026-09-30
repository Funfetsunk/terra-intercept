shader_type canvas_item;

// Palette-safe sprite effects for the player ship.
// - Hit flash: while `flashing` is on, every visible pixel is drawn as one
//   flat palette colour (a silhouette), instead of tinting the sprite with
//   modulate, which would produce off-palette colours.
// - Outline: a 1px palette-coloured outline round the sprite so the ship
//   never gets lost against the background. Frames need a 1px transparent
//   margin so the outline doesn't sample into the next frame of a sheet.
uniform bool flashing = false;
uniform vec4 flash_color : source_color = vec4(1.0);
uniform bool outline_enabled = true;
uniform vec4 outline_color : source_color = vec4(0.561, 0.827, 1.0, 1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a > 0.0) {
		COLOR = flashing ? vec4(flash_color.rgb, c.a) : c;
	} else if (outline_enabled) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float n = texture(TEXTURE, UV + vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV - vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV + vec2(0.0, px.y)).a
			+ texture(TEXTURE, UV - vec2(0.0, px.y)).a;
		COLOR = n > 0.0 ? vec4(outline_color.rgb, 1.0) : c;
	} else {
		COLOR = c;
	}
}
