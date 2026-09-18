# Terra Intercept — Art Dimensions

All sizes are in **game pixels at 1×**. Draw and export at exactly these sizes; Godot scales the whole game up (3× at 1080p, 4× at 1440p). Never upscale art before export.

Keep everything within the fixed 32–48 colour palette, and never use the reserved bullet colours outside bullets.

## Screen layout

| Area | Size | Position |
|---|---|---|
| Full screen | 640×360 | — |
| Playfield (gameplay) | 360×360 | x 140–500 |
| Left HUD panel | 140×360 | x 0–140 |
| Right HUD panel | 140×360 | x 500–640 |
| Dialogue text box | 360×48 | bottom of the playfield |

The font is Press Start 2P on an **8px grid**, and speaker names in dialogue use 9px. Any text drawn into art (logos aside) should respect that scale.

## Player ships

| Item | Size | Frames |
|---|---|---|
| Ship sprite (Interceptor, Striker, Guardian, Vanguard) | 24×24 | 5 banking frames: full left, slight left, level, slight right, full right. One sheet of 120×24. |
| Engine flame | 8×8 | 2–4 frames, looping |
| Hit flash / invincibility | Same as the ship | Can be done in code; no extra art needed |
| Ship-select art | 72×72 (3× the sprite) or 96×96 | 1 frame per ship |

- Each ship's silhouette can suit its role within the 24×24 canvas. For example, the Interceptor could be slim (about 17–19px wide), while the Guardian fills most of the canvas.
- The hitbox is 3–4px at the ship's centre. Keep the cockpit or visual centre there.
- Squad-mates flying in for specials reuse these same sprites.

## Player weapons and ordnance

| Item | Size |
|---|---|
| Primary shots (per ship) | 4×8 to 8×8. A slightly bigger or brighter version at higher power levels is optional. |
| Missile | 4×10, with a 2-frame trail |
| Homing swarm projectile | 4×4 |
| Mine | 8×8, with a 2-frame blink |

## Enemies

| Enemy | Size | Notes |
|---|---|---|
| Drone | 16×16 | |
| Swarmer | 16×16 | Arrives in groups, so keep it simple |
| Lander pod | 16×24 falling, 24×24 deployed | Include 3–4 unfold frames between the two |
| Spinner | 24×24 | A rotation animation or a spinning part |
| Flanker | 20×20 | Enters from the sides and behind |
| Carrier | 32×32 | Larger because it's slow and armoured |
| Sniper | 20×20 | Its laser telegraph is a 1–2px line drawn in code |
| Shielder | 24×24, plus a 40×40 shield ring | |
| Kamikaze | 16×16 | Plus a 2–3 frame "arming" flash |

- Harder variants are palette swaps, so no new drawing is needed.
- Each enemy needs 2–4 idle or movement frames.

## Bosses

| Item | Size | Notes |
|---|---|---|
| Mid-bosses (2–3, reused) | 64×64 | Recoloured for later missions |
| Earth mission bosses | 128–200 on the longest side | Must fit within the 360-wide playfield with room to dodge; 200 wide is the practical maximum |
| Mothership (mission 7) | Wider than the playfield, built from parts | Hull turrets as separate 16–32px pieces, plus a core of about 128×128 |
| Gate Core (final boss) | About 200×200 | Broken into parts that can animate or be destroyed |

Build bosses from **separate parts** (body, turrets, weak points) rather than one big image. This allows animation, per-part destruction and phase changes.

## Enemy bullets

| Item | Size |
|---|---|
| Small bullet | 4×4 |
| Medium bullet | 6×6 |
| Large bullet | 8×8 |
| Laser beam | 4px wide, as a tileable 4×8 segment |

Bullets must be the brightest, most readable things on screen. A 1px outline helps, and the high-contrast option adds one in code.

## Pickups

| Item | Size |
|---|---|
| Weapon power-up | 12×12 |
| Hull repair | 12×12 |
| Special charge | 12×12 |
| Ordnance (missiles, swarm, mines) | 12×12 each |
| Alien tech: small value | 6×6 |
| Alien tech: large value | 8×8 |

Give each pickup a 2–4 frame shimmer or rotation.

## Specials and effects

| Item | Size | Notes |
|---|---|---|
| Vertical line special (Interceptor) | 40 wide × 360 tall | Draw as a tileable 40×40 segment |
| Horizontal line special (Vanguard) | 360 wide × 40 tall | Draw as a tileable 40×40 segment |
| Circle special (Guardian) | 120×120 | 4–6 frames |
| Cone special (Striker) | About 120 wide × 180 long | 4–6 frames; confirm the exact cone angle in-game |
| Small explosion | 16×16 | 6–8 frames |
| Medium explosion | 32×32 | 6–8 frames |
| Large / boss explosion | 64×64 | 8–10 frames; chain several for bosses |
| Respawn bullet-clear ring | About 48×48 | 4–6 frames |

## Backgrounds

| Item | Size | Notes |
|---|---|---|
| Scrolling ground layer | 360 wide, 368 recommended | Tileable vertically, or a long strip. The extra 4px each side covers screen-shake edges. |
| Ground tiles (if using a tileset) | 16×16 | Much less drawing than full painted strips |
| Parallax layers (clouds, smoke, high buildings) | 360 wide | Mostly transparent; tileable vertically |
| Set-piece landmarks (Tower Bridge, pyramids, etc.) | 120–240 wide | Placed onto the ground layer, drawn at an angle so they read from above |

- A 4–6 minute mission scrolls a long way. Build backgrounds from **repeating tiles plus set pieces**, not one huge painting.
- Keep backgrounds lower in contrast than bullets and enemies.

## HUD

| Item | Size |
|---|---|
| Side panel frames (left and right) | 140×360 each |
| Pilot portraits (Dash, Bucky, Max, Tammy) and commander (Steel) | 64×64, with 3–4 expressions each (neutral, determined, hurt, happy) |
| Shield and hull segments | 8×8 per segment, or a bar of about 100×8 |
| Special charge icon | 12×12 |
| Squad-mate selector icons | 16×16 per ship |
| Ordnance type icons | 12×12 |
| Lives icon | 12×12 |
| Focus meter | A bar of about 100×6 |

## Menus and screens

| Item | Size |
|---|---|
| Full-screen backgrounds (title, hangar, world map, results, credits) | 640×360 |
| Title logo | About 320×80 |
| World map node icons | 16×16 |
| Map route lines | 2px wide, drawn in code or as tiles |
| Upgrade icons (hangar list) | 16×16 |
| Mouse aim crosshair | 11×11 (odd size, for a true centre pixel) |
| Cutscene frames (opening invasion, portal approach) | 640×360 |

## Outside the game

| Item | Size |
|---|---|
| Windows app icon | 256×256 (plus 48, 32 and 16), which Godot builds into the .ico |
| GitHub / itch.io banner (later) | 630×500 for itch.io, larger for Steam if ever needed |

## Export checklist

- Export at 1× as PNG with transparency.
- Use one sprite sheet per object, with a consistent frame grid (every frame the same size).
- Keep `.aseprite` sources in `art/source/`, and exported PNGs in `art/sprites/`.
- In Godot, check that imports use nearest filtering and no mipmaps.
