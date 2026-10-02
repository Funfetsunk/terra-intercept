# Terra Intercept — Art Specs

All sizes are in **game pixels at 1×**. Draw and export at exactly these sizes; Godot scales the whole game up (3× at 1080p, 4× at 1440p). Never upscale art before export, and never scale pixel art by fractions in the engine: every `Sprite2D`/`TextureRect` stays at scale 1.

Rows marked **Built** describe the art that is in the game now; the rest are specs for art still to come.

## Palette and style

- **Palette:** Resurrect 64 (Kerrie Lake, Lospec), all 64 colours: `art/palette/resurrect-64.hex`, with an 8×8 swatch at `art/palette/resurrect-64.png` for tools that take a palette image. Every pixel of every sprite is one of these colours. No anti-aliasing, no semi-transparent pixels, and no `modulate` tints on art. Run `python tools/check_palette.py` before committing art; it must report 0 failures.
- **Reserved bullet colours:** pink `f04f78`, cyan `30e1b9`, pale yellow `fbff86`. They are only used for bullets, never in backgrounds, and not as large areas anywhere else.
- **Aliens:** violet armour (`45293f` `6b3e75` `905ea9` `a884f3`) with green glowing cores (`165a4c` `239063` `1ebc73` `91db69`). Enraged or phase-2 states turn the glow red and orange (`9e4539` `e83b3b` `f57d4a` `f9c22b`).
- **Humans:** greys with red, blue and gold accents.
- **Backgrounds** are darkened and desaturated so bullets and ships read on top. Bullets are the brightest things on screen.
- **UI:** grey rim, orange trim and dark fill (the `ui_frame` 9-slice). Selected or focused elements use gold `f9c22b`.
- **Hit flashes** draw a sprite as one flat palette colour (the `silhouette_flash` shader) instead of tinting it. The same shader outlines the player ship in `8fd3ff`.
- **The high-contrast option** outlines enemy bullets only, in `2e222f`.

## Text

The font is Press Start 2P on an **8px grid**. Use font sizes that are multiples of 8 only: **8** for body text, labels and speaker names; **16** for screen titles and main-menu buttons; **32** for single big characters (the results grade). Other sizes put the glyphs off the pixel grid and they draw unevenly. Dialogue speaker names are 8px in gold (`f9c22b`) rather than a larger size. Name labels over busy art get a 2px `2e222f` outline.

Text drawn into art uses its own 3×5 pixel font (the "SQUAD"/"LIVES" plates) or the logo treatment.

## Screen layout

| Area | Size | Position |
|---|---|---|
| Full screen | 640×360 | — |
| Playfield (gameplay) | 360×360 | x 140–500 |
| Left HUD panel | 140×360 | x 0–140 |
| Right HUD panel | 140×360 | x 500–640 |
| Dialogue text box | 560×80 | bottom of the screen, spanning from inside the left HUD panel to inside the right HUD panel (not confined to the playfield width) |

## Player ships

| Item | Size | Notes |
|---|---|---|
| Ship sprite (Interceptor, Striker, Guardian, Vanguard) | 24×24 | **Built.** Banking sheet `<ship>_bank.png`, 120×24: full left, slight left, level, slight right, full right. The bank frames are derived from the level frame (lowered wing foreshortened and shaded darker, raised wing lit, right side mirrored) so all four ships bank the same way. |
| Engine flame | 8×8 | **Built.** 3 frames looping, placed per ship by `ShipData.engine_flame_offsets` (one or two engines). |
| Hit flash | Same as the ship | **Built** in code: a 0.1s palette silhouette (`8fd3ff` on a shield hit, `ffffff` on a hull hit). |
| Player outline | 1px | **Built** in code: the `silhouette_flash` shader draws an `8fd3ff` outline round the ship so it never gets lost in the background. Ship frames keep at least a 1px transparent margin for it. |
| Ship-select art | 72×72 | **Built.** 1 frame per ship. |

- The hitbox is 3–4px at the ship's centre. Keep the cockpit or visual centre there. Art never changes the hitbox.
- Squad-mates flying in for specials reuse these sprites.

## Player weapons and ordnance

| Item | Size | Notes |
|---|---|---|
| Primary shot | 6×6 | **Built.** Pale-yellow diamond, shared by all ships. It is non-directional because twin-stick shots fly in any direction. |
| Ordnance missile | 14×14 frames, 8 facings | **Built.** `ordnance_missile.png`: red nose, grey body, red fins and an orange exhaust, one frame per 45°, clockwise from up. The shot uses the facing nearest its flight direction (`OrdnanceData.bullet_direction_sheet`). The HUD ordnance badges show the same missile. |
| Homing swarm projectile | 4×4 | |
| Mine | 8×8 | 2-frame blink |

Textured bullets are drawn at their own pixel size on whole pixels. The collision radius is set separately in data, so art never changes a hitbox.

## Enemies

| Enemy | Size | Notes |
|---|---|---|
| Drone | 16×16 | **Built.** 2-frame core pulse. |
| Swarmer | 16×16 | **Built.** 2-frame glow pulse. |
| Lander pod | 24×24 frames | **Built.** 16×24 pod centred in the frame while falling, then an unfold frame, then 2 deployed frames. |
| Spinner | 24×24 | **Built.** Spins through 4 exact 90° rotations, so no resampling. |
| Flanker | 20×20 | **Built.** Dart shape pointing right, rotated in whole quarter turns to face its entry direction. 2-frame glow pulse. Plus an 8×8 amber (`f9c22b`) warning chevron that blinks at the playfield edge before it enters. |
| Carrier | 32×32 | **Built.** Larger because it's slow and armoured. `idle` is a 2-frame glow pulse; `open` shows the bay lit green (the launch telegraph). |
| Burrower | 20×20 | **Built.** 2-frame glow pulse. While it's underground, a 3-frame puff (`burrower_puff_snow` / `burrower_puff_sand`, 20×20, light chunks plus `2e222f` debris) and an 18×8 `2e222f` shadow mark the spot. |
| Sniper | 20×20 | **Built.** 2-frame glow. Its laser telegraph is an `f9c22b` line drawn in code: 1px, then 2px, blinking while locked. |
| Crawler | 24×24 | **Built.** `idle` 2-frame glow, `charge` flashes the turret core orange before a burst. |
| Mine layer | 24×24 | **Built.** Faces right and mirrors to cross left. Its mines are 8×8 (`mine.png`): violet body, amber spikes, core blinking `9e4539`/`fbb954`. |
| Shielder | 24×24, plus a 40×40 shield ring | |
| Kamikaze | 16×16 | Plus a 2–3 frame "arming" flash |

- Every enemy is an `AnimatedSprite2D` with a `SpriteFrames` resource sliced from a uniform-grid sheet.
- Each enemy needs 2–4 idle or movement frames. Harder variants are palette swaps within the alien ramps.
- **Mk II (columns 4–6), built:** every enemy has a `<name>_mk2.png` sheet and `<name>_mk2_frames.tres`. Violet steps down one shade (`a884f3→905ea9`, `905ea9→6b3e75`, `6b3e75→45293f`, `eaaded→a884f3`) and the green glow becomes amber (`165a4c→9e4539`, `239063→cd683d`, `1ebc73→e6904e`, `91db69→f9c22b`, `cddf6c→fbb954`). The frames have the same animation names as the base frames, and `EnemyData.sprite_frames` swaps them in.

## Bosses

| Item | Size | Notes |
|---|---|---|
| Mid-boss | 64×64 | **Built.** Alien gunship. `phase1` (green core pulse) and `phase2` (red core) animations. Reused and recoloured for later missions. |
| Tower Bridge boss | 168×112 | **Built.** Drawn at an angle so it reads from above, standing on the Thames. `phase2` swaps to a battle-damaged version with a flickering core. The ground scroll locks while it's on screen. |
| Seine siphon boss (Paris) | 168×112 | **Built.** Four-legged siphon rig standing in the Seine, green fluid tanks. `phase2` is battle-damaged, its core flickering between green and red. The ground scroll locks while it's on screen. |
| Glacier drill rig (Fjords) | 168×112 | **Built.** Armoured rig with turrets, two drill arms and a meltwater tank, its drill biting into the glacier front set piece. `phase2` is battle-damaged, its tank and debris flickering green and red. The ground scroll locks while it's on screen. |
| Harvester convoy (Siberia) | Engine 48×32, tanker cars 32×24 | **Built.** Separate parts that face right and mirror (flip_h, pixel-exact) when driving left. The engine's `shielded` animation has a green core, and `exposed` turns it orange. |
| Pyramid fortress (Cairo) | 168×128 | **Built.** The Great Pyramid with an alien ship fused on, and stone mapped to dusky `694f62`/`966c6c` so it stands off the orange sand. `phase2` has the capstone split open into a red core and the face hatches burning. |
| Escort mothership (mid-boss, columns 4–6) | 64×64 | **Built.** Twin launch bays and a core. `phase2` turns the glow orange. |
| Serpent dragon (Great Wall) | Head 48×48, segments 24×24 | **Built.** Separate parts. Segments are round discs, so they never need rotating. `phase2` turns the head's glow orange. |
| Summit relay (Himalayas) | 168×128 | **Built.** A spire with four dishes. The snow base is mapped to muted greys and trimmed to a jagged peak so it never ends in a straight edge. `phase2` turns the coils orange. |
| Other Earth mission bosses | 128–200 on the longest side | Must fit within the 360-wide playfield with room to dodge; 200 wide is the practical maximum |
| Mothership (mission 7) | Wider than the playfield, built from parts | Hull turrets as separate 16–32px pieces, plus a core of about 128×128 |
| Gate Core (final boss) | About 200×200 | Broken into parts that can animate or be destroyed |

The built bosses are single images with a phase-2 variant. Later bosses that need per-part destruction should be built from separate parts (body, turrets, weak points).

## Enemy bullets

| Item | Size | Notes |
|---|---|---|
| Small / medium orb | 6×6 | **Built.** Pink (`c32454` rim, `f04f78` body, white core) and cyan (`0b8a8f` / `30e1b9` / white). |
| Large orb | 8×8 | **Built.** Same two colours, used by the bosses. |
| Small bullet (later) | 4×4 | |
| Laser beam (later) | 4px wide, as a tileable 4×8 segment | |

The high-contrast option draws a dark outline behind every bullet in code.

## Pickups

| Item | Size | Notes |
|---|---|---|
| Weapon power-up | 12×12 | **Built.** Red badge with a "P". 4-frame glint. |
| Hull repair | 12×12 | **Built.** Green badge with a cross. |
| Special charge | 12×12 | **Built.** Blue badge with a bolt. |
| Ordnance pickups | 12×12 each | |
| Alien tech: small / large | 6×6 / 8×8 | **Built.** Lavender gems. Drops worth 2 or more use the large gem. |

Highlighted tutorial pickups bob by whole pixels. They never pulse in scale.

## Specials and effects

| Item | Size | Notes |
|---|---|---|
| Line specials (Interceptor, Vanguard) | Data-driven size | **Built** in code: a banded energy beam (white core, then `8fd3ff`, then `4d9be6`, with a dithered edge) with travelling pulses. |
| Circle and cone specials (Guardian, Striker) | Data-driven size | **Built** in code: 2px palette bands rippling outward inside a solid edge. |
| Small / medium / large explosion | 16 / 32 / 64 | **Built.** 6 / 8 / 10 frames in the palette fire ramp, fading to smoke. Large also plays when the player's hull breaks. |
| Respawn bullet-clear ring | 128×128 frames | **Built.** 6 frames expanding to the 60px clear radius, then dithering out. |

All effects end by blinking or dithering out, never by alpha fading.

## Backgrounds

| Item | Size | Notes |
|---|---|---|
| Scrolling ground layer | 360×360 tiles | **Built** (London, Paris, Fjords, Siberia, Cairo): two tiles per mission (`thames_a`/`thames_b`, `seine_a`/`seine_b`, `fjord_a`/`fjord_b`, `tundra_a`/`tundra_b`, `desert_a`/`desert_b`, `wall_a`/`wall_b`, `slopes_a`/`slopes_b`). Siberia's B tile is A mirrored vertically, because its diagonal streams can't wrap any other way. Cairo uses the same tile twice, because its winding road can't be mirrored that alternate seamlessly. Any B tile must keep A's top and bottom edges. The HUD panels cover the playfield's side edges, so no screen-shake margin is needed. |
| Parallax layers (clouds, smoke) | 360×360 | **Built** (London): a dithered `smoke.png` haze, about 8% coverage, at 1.4× scroll. |
| Space / test range | 360×360 | **Built:** a palette starfield. |
| Set-piece landmarks | 120–240 on the longest side | Drawn at an angle so they read from above. **Built:** the Eiffel Tower (96×160, `backgrounds/paris/eiffel_tower.png`), a `SetPiece` scene that scrolls with the ground once, spawned from the mission timeline. Mapped darker than the gameplay layer, like the tiles. Also the glacier front (360×200, `backgrounds/fjords/glacier_front.png`), which slides in under the Fjords boss and stops when the scroll locks. |
| Fjord cliff walls | 124×104, tiles vertically | **Built:** `backgrounds/fjords/cliff_rock.png`, a seamless rock-and-pine texture drawn by `FjordWalls` up to 118px deep on each side, with a 1px `9babb2` rim and a 3px `2e222f` shadow on the water side. Snow is mapped to `7f708a` so the walls stay background-dark. |

Layers scroll on whole pixels. Keep backgrounds darker and lower in contrast than everything in the gameplay layer.

## HUD

| Item | Size | Notes |
|---|---|---|
| Side panel frames | 140×360 each | **Built.** Left panel: shield, hull and focus rows, ordnance grid and lives box. Right panel: special-meter row, 3 charge sockets, a SQUAD box, and tech, score and chain readout rows (icon socket plus a flat dark track with 8px text). |
| Pilot portraits (Dash, Bucky, Max, Tammy) and commander (Steel) | 64×64 | **Built.** 4 expressions each (neutral, determined, hurt, happy), hand-tuned onto the palette. Skin and hair map onto one warm ramp (`2e222f` … `fdcbb0`) with a lightness offset per character (Dash 0, Tammy +2, Bucky −4, Max −10, Steel −12), so each skin tone keeps its depth. |
| Shield / hull / focus / special bar tile | 5×10 | **Built.** 4px of art plus a 1px transparent column, tiled to fill a 65×10 track. |
| Special charge icon | 12×12 | **Built.** Reuses the special-charge pickup badge. |
| Squad-mate icon | 24×24 | **Built.** Reuses the ship's level frame. |
| Ordnance ammo badge | 36×29 | **Built.** A fixed 2×3 grid; each badge shows or hides per remaining shot. |
| Lives digit | 23×40 | **Built.** Digit sheet `ui_0`–`ui_9`, one swapped in to match the lives count. |

## Menus and screens

| Item | Size | Notes |
|---|---|---|
| Menu backdrop | 640×360 | **Built.** Shared by slot select, ship select, options, hangar, results, game over and briefings: Earth's horizon and a nebula. |
| Title background and logo | 640×360; logo 251×90 | **Built.** The logo is Press Start 2P at 6× and 3× with a bevel, extrusion and outline. |
| World map | 640×360 | **Built.** A tactical world map. Each node's `map_position` is its real location, from a projection fitted to the image (Europe nudged apart slightly so icons don't overlap). |
| World map node icons | 16×16 | **Built.** Completed (check), available (blinking target, 2 frames), locked (padlock). |
| Map route lines | 2px | **Built** in code: solid gold when open, dim dashes when locked. Long routes wrap round the Pacific. |
| Upgrade icons (hangar list) | 16×16 | **Built.** Cut from the matching HUD icons. |
| UI frame | 16×16 9-slice, 6px margins | **Built.** `ui_frame` plus focus, pressed and disabled variants, used for buttons, dialogue and panels. |
| Mouse aim crosshair | 11×11 | **Built.** White ticks and a centre dot with a dark outline, drawn in game pixels on its own layer (not as the OS cursor, which wouldn't scale). |
| Cutscene frames | 640×360 | |

## Outside the game

| Item | Size |
|---|---|
| Windows app icon | 256×256 (plus 48, 32 and 16), which Godot builds into the .ico |
| GitHub / itch.io banner (later) | 630×500 for itch.io, larger for Steam if ever needed |

## Export and import checklist

- Export at 1× as PNG with transparency.
- One sprite sheet per object, with a uniform frame grid (every frame the same size). Frames laid out left to right.
- Keep `.aseprite` sources in `art/source/`, and exported PNGs in `art/sprites/`.
- Imports use nearest filtering and no mipmaps (the project import preset handles this).
- Run `python tools/check_palette.py` and fix every failure before committing.
