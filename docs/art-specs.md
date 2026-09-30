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
- **Hit flashes** draw a sprite as one flat palette colour (the `silhouette_flash` shader) instead of tinting it.

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
| Ship-select art | 72×72 | **Built.** 1 frame per ship. |

- The hitbox is 3–4px at the ship's centre. Keep the cockpit or visual centre there. Art never changes the hitbox.
- Squad-mates flying in for specials reuse these sprites.

## Player weapons and ordnance

| Item | Size | Notes |
|---|---|---|
| Primary shot | 6×6 | **Built.** Pale-yellow diamond, shared by all ships. It is non-directional because twin-stick shots fly in any direction. |
| Ordnance bomb | 10×10 | **Built.** Bomb with a lit fuse, matching the HUD ordnance badge. |
| Missile (later ordnance type) | 4×10 | 2-frame trail |
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
| Flanker | 20×20 | Enters from the sides and behind |
| Carrier | 32×32 | Larger because it's slow and armoured |
| Sniper | 20×20 | Its laser telegraph is a 1–2px line drawn in code |
| Shielder | 24×24, plus a 40×40 shield ring | |
| Kamikaze | 16×16 | Plus a 2–3 frame "arming" flash |

- Every enemy is an `AnimatedSprite2D` with a `SpriteFrames` resource sliced from a uniform-grid sheet.
- Each enemy needs 2–4 idle or movement frames. Harder variants are palette swaps within the alien ramps.

## Bosses

| Item | Size | Notes |
|---|---|---|
| Mid-boss | 64×64 | **Built.** Alien gunship. `phase1` (green core pulse) and `phase2` (red core) animations. Reused and recoloured for later missions. |
| Tower Bridge boss | 168×112 | **Built.** Drawn at an angle so it reads from above, standing on the Thames. `phase2` swaps to a battle-damaged version with a flickering core. The ground scroll locks while it's on screen. |
| Other Earth mission bosses | 128–200 on the longest side | Must fit within the 360-wide playfield with room to dodge; 200 wide is the practical maximum |
| Mothership (mission 7) | Wider than the playfield, built from parts | Hull turrets as separate 16–32px pieces, plus a core of about 128×128 |
| Gate Core (final boss) | About 200×200 | Broken into parts that can animate or be destroyed |

The two built bosses are single images with a phase-2 variant. Later bosses that need per-part destruction should be built from separate parts (body, turrets, weak points).

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
| Scrolling ground layer | 360×360 tiles | **Built** (London): two tiles, `thames_a` and `thames_b`, that alternate seamlessly. Any B tile must keep A's top and bottom edges. The HUD panels cover the playfield's side edges, so no screen-shake margin is needed. |
| Parallax layers (clouds, smoke) | 360×360 | **Built** (London): a dithered `smoke.png` haze, about 8% coverage, at 1.4× scroll. |
| Space / test range | 360×360 | **Built:** a palette starfield. |
| Set-piece landmarks | 120–240 wide | Drawn at an angle so they read from above |

Layers scroll on whole pixels. Keep backgrounds darker and lower in contrast than everything in the gameplay layer.

## HUD

| Item | Size | Notes |
|---|---|---|
| Side panel frames | 140×360 each | **Built.** Left panel: shield, hull and focus rows, ordnance grid and lives box. Right panel: special-meter row, 3 charge sockets and a SQUAD box. |
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
| Mouse aim crosshair | 11×11 | Odd size, for a true centre pixel |
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
