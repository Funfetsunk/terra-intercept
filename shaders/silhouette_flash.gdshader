shader_type canvas_item;

// Hit flash that stays on the palette: while `flashing` is on, every visible
// pixel is drawn as one flat palette colour (a silhouette), instead of
// tinting the sprite with modulate, which would produce off-palette colours.
uniform bool flashing = false;
uniform vec4 flash_color : source_color = vec4(1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	COLOR = flashing ? vec4(flash_color.rgb, c.a) : c;
}
