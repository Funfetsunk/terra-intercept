# CLAUDE.md — Terra Intercept

Terra Intercept is a 2D pixel-art vertical-scrolling bullet hell with twin-stick controls, built in Godot. It's a hobby project with a 90s arcade feel.

**The full design lives in `docs/design-summary.md`. Read it before building any gameplay feature.** Art dimensions live in `docs/art-specs.md`. Don't invent design decisions. If something isn't covered there or is unclear, ask before implementing.

## Current milestone

Milestone 1 (vertical slice) — complete (tag `vertical-slice`).
Milestone 2a (core systems) — complete (tag `milestone-2a`).
Milestone 2b (London, mission 1) — complete (tag `milestone-2b`).
Milestone 3 (campaign structure) — complete. All 9 tasks below done. No git tag cut yet — say the word if you want one.

**Art pass: complete** (2026-09-30). All of London, the HUD, the menus and the map have real on-palette art (see "Art" below).

**London: complete** (tag `london-complete`, 2026-09-30). Difficulty tuned after playtesting, and pause menu, crosshair and HUD readouts are in. The developer playtested on the retro laptop with no noticeable slowdown; an exact 60fps figure hasn't been measured (a debug FPS counter is an option if later missions get busier). Sound effects and the Sound Test wait until the developer has the sounds ready, and the music tracks are still placeholders.

**Now: mission 2** (column 2: Norwegian Fjords, north lane; Paris, south lane). Decisions are in `docs/design-summary.md`, and the enemy roster (`docs/enemy-roster.md`) is approved. **Paris** (slightly harder than London) has been playtested and approved. The Norwegian Fjords are built (about Paris's difficulty).

Column 3 is built: Siberian Ice (north) and Cairo (south), a step harder than column 2.

**Column 4 is built and ready to playtest:** the Great Wall (north) and the Himalayas (south), with Mk II enemies, the Sniper, the Crawler, the Mine layer and the escort mid-boss. The decisions are in `docs/design-summary.md`.

Milestone 3 built the frame around the mission that already works: saves, the hangar, upgrades, the world map and the story screens.

Build in this order, one task at a time, committed separately. Mark each **[done]** when finished and committed.

1. **Art pipeline. [done]** Set up the import path for real art before any lands: folder convention, sprite-sheet format, and an import preset with nearest filtering and no mipmaps. Verify it with one real asset end to end (import → animation → in-game). Recorded under "Art" below.
2. **SaveManager and save slots. [done]** 3 slots. A save holds: selected ship, map position, banked alien tech, upgrades owned, the purchase ledger (see task 4), mission results and high scores. Saving happens **only** on mission completion. Add a slot-select screen with create, continue and delete.
3. **Run state. [done]** Extend `GameState` to hold everything a run needs so the hangar and map can read it: current column, lane, completed missions, tech, upgrades, and difficulty.
4. **Upgrades. [done]** Upgrade definitions in `.tres`: id, name, description, cost, the stat it changes, its maximum level, and the map column that unlocks it. Apply them to player stats at mission start. Keep a **purchase ledger** of what was bought since the last completed mission, so a return to the hangar after a game over refunds exactly those purchases and nothing earlier.
5. **Hangar screen. [done]** Spend alien tech on the available upgrades, show what's locked and why ("unlocks at column 3"), and handle the refund rule from task 4. Reachable from the map, and after a game over.
6. **World map. [done]** 6 columns in two lanes, with a lane choice after columns 1, 3 and 5, converging on mission 7. Show completed, available and locked missions. Cleared missions can be replayed for tech. The map position is saved.
7. **Story screens. [done]** Pre- and post-mission briefings using the existing portrait-and-text-box system, driven by dialogue `.tres` files. Mission-specific briefings, plus the column-4 midgame reveal, which must work on every route.
8. **Full flow. [done]** Title → slot select → ship select (new run only) → map → briefing → mission → results → post-briefing → hangar → map. Game over offers restart or hangar, with the refund rule applied. Landed as a byproduct of tasks 2, 5, 6 and 7 building the chain incrementally -- verified as its own pass with a full live playthrough (including forcing a game over) rather than built fresh.
9. **Settings. [done]** The `Settings` autoload and an options screen: CRT filter, screen shake, button remapping, high-contrast bullets, difficulty (Easy/Normal). Settings save separately from run saves.

**Not yet:** sound effects and the Sound Test (the developer will provide the sounds), missions from column 5 onwards, co-op. Ask before starting any of these.

Every milestone must run at a steady 60fps on the retro laptop (i7-1165G7 / Iris Xe).

## Art

The full art spec, including what is built, sizes, palette, reserved colours and style rules, lives in `docs/art-specs.md`. Read it before making or placing any art. Claude owns art direction (since 2026-09-30) and keeps everything consistent with that doc.

**Rules:**
- **Palette:** Resurrect 64 only (`art/palette/resurrect-64.hex`; `resurrect-64.png` is the same as an 8×8 swatch for tools). No anti-aliasing, no semi-transparent pixels, and no `modulate` tints on art. Textured bullets and pickups use a white `bullet_color` for this reason, and hit flashes use the `silhouette_flash` shader. Before committing art, run `python tools/check_palette.py`; it must report 0 failures.
- **Reserved bullet colours:** pink `f04f78`, cyan `30e1b9`, pale yellow `fbff86`. They never appear in backgrounds.
- **No fractional scaling:** every `Sprite2D`/`TextureRect` stays at scale 1, and effects never pulse in scale. If an incoming asset doesn't match `docs/art-specs.md`, ask instead of rescaling.
- **Text:** Press Start 2P at 8, 16 or 32px only. Other sizes break the pixel grid. Speaker names are 8px gold, not a larger size.
- **Hitboxes and collision shapes never change** when art changes. Collision radii live in data.
- **Art changes are their own tasks.** Never interrupt the current task to swap art in: finish, commit, then do the art as its own commit.
- **Placeholder art** from asset packs lives in `art/placeholder/<pack-name>/` with a source/licence note. Nothing in a live scene references it now. New missions may use it until their art is made.

**How art gets made:** PixelLab (MCP) output is never committed raw. It's remapped onto the palette, by hand-mapping colours where a nearest-colour match looks wrong. Small items (bullets, pickups, explosions, effects, UI frames, bank frames, icons, the logo) are drawn procedurally in palette so they stay consistent. The remap and drawing scripts are session scratch, not repo code. Portraits and ship-select art were hand-tuned (per-character skin offsets, see `docs/art-specs.md`) rather than regenerated, to keep the developer's commissioned art.

**Engine conventions for art:**
- Animated art is an `AnimatedSprite2D` plus a `SpriteFrames` resource sliced from a uniform-grid sheet. One-shot effects are small scenes in `scenes/effects/` that free themselves (`explosion.gd`).
- Placeholder→art swaps keep the old `ColorRect` as a sizing wrapper, with a child `TextureRect` named "Art". A `ColorRect` can't be retyped in place.
- Menu buttons, dialogue and panels are styled by `themes/main_theme.tres` (`button_*.tres` 9-slice StyleBoxTextures) and `themes/panel_frame.tres`.
- `BackgroundLayer` takes its art from `panel_a_texture` / `panel_b_texture` exports, because property overrides on an instanced scene's child nodes don't persist. It places panels on whole pixels.
- The pipeline import preset (`importer_defaults/texture`) is no mipmaps and lossless, and the default texture filter is Nearest.

## What already exists

Context for anything built from here on.

- **London** runs end to end: a three-section mission (tutorial / Thames run / boss) with marker-based restarts, the non-lethal tutorial, skip-tutorial, drone / swarmer / lander pod, a reusable mid-boss, the two-phase Tower Bridge boss, and the title → slot select → ship select (new run only) → map → London → results → hangar → map flow.
- **Paris** (`scenes/levels/paris.tscn`, map id `col2_south`) runs end to end: a Seine run (0–250s) and the Seine siphon boss (section `boss` at 250s). There's no tutorial. It debuts the Flanker and brings in the Spinner, reuses the Sentinel mid-boss at 128s with harder Paris data (`paris_mid_boss_data.tres`: hull 180, aimed secondary fans), and scrolls the Eiffel Tower past at 88s as a set piece. It's denser than London, with late pattern variants from 160s. The 461 spawns are embedded as sub-resources in `data/missions/paris_mission.tres` rather than one file each like London. They were generated from a script, so to retune the timeline, regenerate the file instead of editing hundreds of entries by hand. Its Steel briefing lines are drafts for the developer to review.
- **Norwegian Fjords** (`scenes/levels/fjords.tscn`, map id `col2_north`) runs end to end: a fjord run (0–250s, restart section `boss` at 246s so the glacier set piece respawns) and the glacier drill rig boss at 250s. It debuts the Carrier, brings in the Spinner, and reuses the Sentinel mid-boss at 128s (`fjords_mid_boss_data.tres`, currently the same tuning as Paris). Its twist is the cliff walls (see `FjordWalls`). There are no Flankers or lander pods: the Flanker debuts in the other lane, and pods would land on water. The 383 spawns and the wall shape were generated together, so spawn x positions sit inside the open channel at the time each enemy arrives. Regenerate both together when retuning. Its Steel briefing lines are drafts for the developer to review.
- **Fjord walls** (`scenes/levels/fjord_walls.gd`, a `FjordWalls` node under `PlayfieldRoot` just after `PlayerShip`, so it runs after the player moves): the shape comes from `MissionData.wall_keys`, a `PackedVector3Array` of (distance scrolled in px, left width, right width), smoothstepped between keys. The walls scroll with the ground and stop when a boss locks the scroll. Touching a wall pushes the player back into the channel and deals `contact_damage` through `take_hit()` (so invincibility frames apply), with a cooldown. The edge is drawn in `band_height` strips with deterministic jitter. To keep the Grand Canyon (column 6) distinct, give it a different profile and timing.
- **Carrier** (`scenes/enemies/carrier.gd`): drifts down at `move_speed` to `cruise_y`, then crawls at `cruise_speed` while it launches up to `max_launches` copies of `launch_scene` (swarmers) every `launch_interval`. The bay sprite (`open` animation) lights up `bay_open_duration` before each launch. When it has finished launching, it leaves at full speed.
- **Mission outros and screen fades:**
  - `scenes/ui/screen_fade.tscn` is a CanvasLayer (layer 60, runs while paused) with a full-screen `ColorRect` using `shaders/dither_fade.gdshader`. That shader is a 4×4 ordered-dither dissolve to `2e222f`: each pixel is either the fade colour or untouched, so the screen never shows off-palette blended colours.
  - `fade_in_on_ready` dissolves the scene in on arrival. `await fade_out()` is called before changing scene.
  - It's instanced in every level and in the results and game-over screens. New levels and any menu that should fade need it too.
  - **Boss kill:** `mission_level.gd` clears enemy bullets and calls `PlayerShip.play_victory_exit()`. Player control and damage stop, the ship hovers for `victory_hover_duration`, accelerates off the top and emits `victory_exit_finished`. The level then fades out to the results screen.
  - **Last life lost:** the player is hidden and disabled after its death explosion, and the level waits `game_over_delay` before fading out to the game-over screen.
  - The pause menu is disabled once either outro starts.
- **Column 3** (Siberia `scenes/levels/siberia.tscn` / `col3_north`, Cairo `scenes/levels/cairo.tscn` / `col3_south`):
  - Both share one generated timeline shape: 449 spawns, with the Burrower debuting gently from 24s.
  - The Flanker and Carrier join the pool, along with landers and spinners. Late variants start from 130s.
  - The mid-boss is the Sentinel on `col3_mid_boss_data.tres` (hull 210).
  - Siberia's Burrowers use `burrower_ice.tscn`; Cairo's use `burrower_sand.tscn`.
  - Steel's briefing lines are drafts.
- **Burrower** (`scenes/enemies/burrower.gd`): spawns underground at its spawn position (inside the playfield) and rides the ground scroll. A puff and blinking shadow mark it for `telegraph_duration`, then it surfaces, fires `surface_pattern` once (a ring) and keeps firing its aimed pattern. While underground, `get_hitbox_radius()` is negative, so nothing can hit it or be hit by it.
- **Fog banks** (Siberia, `scenes/levels/fog_banks.gd`):
  - Shape: `MissionData.fog_banks` holds (distance, length px, density 0-1). The fog drifts at 1.25× ground speed, and keeps drifting slowly while a boss has the ground locked.
  - Drawing: the child `Fog` ColorRect runs `shaders/fog_dither.gdshader`, an ordered dither in `c7dcd0`/`9babb2` with soft edges and drifting wisps.
  - Draw order: the node sits at `z_index` 5, above enemies and bullets. Siberia's `PlayerShip` is set to `z_index` 6 so the player stays visible.
  - Timing: a bank at distance d first shows at the top at t = (d − 360) / 50.
- **Sand gusts** (Cairo, `scenes/levels/sand_gusts.gd`, placed after `PlayerShip`):
  - Shape: `MissionData.gusts` holds (start s, duration s, push px/s; negative pushes left).
  - Warning: for `telegraph_duration` before a gust, three amber chevrons blink at the upwind edge.
  - During a gust the player is pushed sideways, eased in and out, while sand streaks race across the screen.
- **Harvester convoy boss** (`scenes/bosses/convoy_boss.tscn`):
  - A `ConvoyBoss` Node2D (not an enemy itself) drives a `ConvoyEngine` and five `ConvoyCar` instances (`slot` 1–5) round an oval track, placing each part by distance along the track.
  - The engine is shielded (it ignores damage) until every car is destroyed. It then switches to its BossData phase-2 patterns and phase-2 music, and its death completes the mission.
  - It locks the ground scroll once the engine reaches the track.
- **Column 4** (Great Wall `scenes/levels/great_wall.tscn` / `col4_north`, Himalayas `scenes/levels/himalayas.tscn` / `col4_south`):
  - Regular enemies are Mk II through spawn `data_override`s (`*_mk2_data.tres`). Carriers use the `carrier_mk2.tscn` scene so they launch `swarmer_mk2.tscn`.
  - The mid-boss is the new escort mothership (`escort_mid_boss.tscn`) at 128s.
  - Both missions are generated from one script. The Great Wall adds Crawlers and pan keys and leaves out landers and Burrowers (they don't follow the pan). The Himalayas adds Mine layers, landers, Burrowers and avalanches.
  - Steel's briefing lines are drafts. The Himalayas post-briefing teases the midgame reveal.
- **Mk II variants:** `EnemyData.sprite_frames` (optional) replaces an enemy's art in `EnemyBase._ready()`, keeping the current animation, so a variant is just data: Mk II sheet, frames, harder pattern (+1 bullet, or +2 on rings, plus 10% speed) and +25% hull. The fan and tight overrides are `drone_pattern_fan_mk2` / `swarmer_pattern_tight_mk2`.
- **Sniper** (`scenes/enemies/sniper.gd`): drops to `hold_y`, then for each of `shots` shots draws a laser line that tracks the player. The line thickens, locks for `lock_time` (blinking), then a fast `burst_size` bullet line fires along it. The Sniper climbs away after its last shot.
- **Crawler** (`scenes/enemies/crawler.gd`): rides the ground scroll and follows the ground pan through the `ground_pan` group. Its spawn x is read in ground space, so relative 0.5 is always on the Wall. The `charge` animation plays for `charge_time` before each burst.
- **Mine layer and mines** (`mine_layer.gd`, `mine.gd`):
  - The Mine layer crosses at its spawn height from the side it spawns on, dropping `mine_scene` every `drop_interval`.
  - Mines arm, then pop into a ring when the fuse runs out or the player comes within `trigger_radius`. They blink faster just before. A pop gives no score; shooting a mine first is safe.
- **Ground pan** (Great Wall, `scenes/levels/ground_pan.gd`): `MissionData.pan_keys` holds (distance, pan px), smoothstepped. It calls `BackgroundLayer.set_pan()`; a layer only pans when its `pan_margin` is above 0. The FarLayer uses 60, so its panels are drawn 60px wider on each side and the tile must wrap seamlessly left to right. The Wall tile is rolled so the Wall sits at x 240 of the tile, which is screen centre at pan 0.
- **Avalanche lanes** (Himalayas, `scenes/levels/avalanche_lanes.gd`, after `PlayerShip`, `z_index` 4, with the player at 6):
  - Shape: `MissionData.avalanches` holds (start s, lane centre 0-1, lane width px).
  - Warning: for `telegraph_duration`, amber chevrons point down at the top of the lane and snow trickles down it.
  - Slide: a dithered slab (fog shader on the `Slide1` / `Slide2` ColorRects, white `ffffff`/`c7dcd0`) sweeps down at `slide_speed`. It hits the player once for `damage`, destroys non-boss enemies and clears enemy bullets in its path. Up to two slides can run at once.
- **Serpent boss** (`scenes/bosses/serpent_boss.tscn`):
  - The `SerpentBoss` Node2D dives the `Head` (SerpentHead, BossData) in from the top, then weaves it in a figure-of-eight.
  - The eight `SerpentSegment` instances (`slot` 1–8) follow the head's recorded trail at `segment_spacing`, and segments can be shot off.
  - The head is the core: phase 2 at 50% speeds the serpent up, and its death explodes the remaining body and completes the mission.
- **Escort mid-boss** (`scenes/bosses/escort_mid_boss.gd`, extends `mid_boss.gd`): launches `launch_scene` (Mk II swarmers) from alternating `bay_offsets`, every `launch_interval` (`phase2_launch_interval` in phase 2).
- **Patterns:** `BulletPatternData.emitter_angle_offsets` adds a per-emitter angle (matched by index to `emitter_offsets`). The relay's dish beams use it to sweep out of step.
- **Shared level script:** every mission level uses `scenes/levels/mission_level.gd` (exports `mission_id`, which must match the `MapNodeData` id, and `has_tutorial`). It records `GameState.current_level_path` and `current_level_has_tutorial`, so the game-over screen restarts the right level and only offers "Skip tutorial" where there is one. It also runs the outros (see above), so every level needs a `ScreenFade` child. London's own `london.gd` is gone. A new level is London's structure without the `TutorialSequencer`, with its own mission resource on `DialogueController`, `Background` and `EnemySpawner`, and its own tile textures on `FarLayer`.
- **Stage boss script:** `scenes/bosses/stage_boss.gd` (formerly `tower_bridge_boss.gd`) is the generic final boss. It moves into place, locks the ground scroll, runs two phases with secondary patterns, and completes the mission on death. Each boss is just a scene (`Sprite` `AnimatedSprite2D` with `phase1`/`phase2`, plus `Hitbox`) and a `BossData`.
- **Flanker** (`scenes/enemies/flanker.gd`): its entry side comes from the spawn position (relative x < 0 enters from the left, x > 1 from the right, otherwise from below, so use y ≈ 1.1). A warning chevron blinks at that edge for `telegraph_duration`, then it crosses on a sine sway, firing only once inside the playfield.
- **Set pieces** (`scenes/levels/set_piece.gd`, scenes in `scenes/levels/set_pieces/`): one-off landmarks spawned through a `SpawnEntry` that scroll at the ground layer's speed (`ScrollingBackground.get_ground_speed()`), sit at `z_index` -9 (above the tiles, below gameplay) and free themselves once off-screen.
- **Spinner** gained `hover_duration` (0 = hold forever, the old behaviour; the scene sets 7s) and `exit_speed`, so it sinks away instead of piling up across a long mission.
- **Saves:** `SaveManager` autoload, 3 slots at `user://saves/slot_N.tres`, holding a `SaveData` resource (`scripts/resources/save_data.gd`). Written only from `GameState.mission_completed` — Create/Continue never touch disk. Slot identity keys off `ShipData.ship_name` (no dedicated ship id exists) and mission results/high scores key off `GameState.current_mission_name` (set per-level, e.g. `"London"` in `london.gd`). Purchase ledger keys off `{id, cost}` records, see the Upgrades bullet below.
- **Run state:** `GameState` holds persistent run fields (`current_column`, `current_lane`, `completed_missions`, `banked_tech`, `upgrades_owned`, `purchase_ledger`, `difficulty`) separate from per-mission fields (`mission_tech`, `score`, etc.) that `start_new_run()` resets each mission. `complete_mission()` banks `mission_tech` into `banked_tech`, records the mission as completed (no duplicates on replay), and clears `purchase_ledger` (locking in purchases). `SaveManager` mirrors all of these to/from `SaveData` on continue/complete, and `begin_new_run()` resets them all for a fresh run. `difficulty` is a placeholder default ("Normal") until the `Settings` autoload (task 9) exists as its real source — GameState will mirror it, not own it. When typing a `GameState`/`SaveManager` reference as plain `Node` (no `class_name` on either), an untyped `[]`/`{}` literal assigned to a typed-array/dictionary property fails at runtime through the dynamic `set()` path — use `.duplicate()` off an existing typed value, or an explicit `as Array[T]` cast.
- **Upgrades:** `UpgradeData` resource (`scripts/resources/upgrade_data.gd`) — `id`, `upgrade_name`, `description`, `cost`, `stat_name`, `value_per_level`, `max_level`, `unlock_column`. Three examples in `data/upgrades/` (more hull, stronger shields, special meter rate), wired via `GameState.all_upgrades`. `GameState.purchase_upgrade(id)` validates cost/max-level/column-unlock, deducts `banked_tech`, and records `{id, cost}` in `purchase_ledger`; `refund_ledger()` reverses it exactly. Applied at mission start in `player_ship.gd`: `data` is duplicated (`data.duplicate()`) before any upgrade is added, so the shared authored `ShipData` `.tres` is never mutated.
- **Hangar screen** (`scenes/menus/hangar.tscn`/`.gd`): one `upgrade_row.tscn` instance per `GameState.all_upgrades` entry, dynamically instantiated (data-driven list, not a fixed count like `ship_select`'s four ships) -- shows name/description/cost/level, a locked row shows "Locked — column N" instead of a Buy button, a maxed row shows "Maxed". Buying one upgrade must refresh every row's afford-state, not just its own — a real bug caught in testing (tech dropped below a second upgrade's cost, but that row's Buy button stayed enabled until something else touched it). Results screen routes its Continue button through the Hangar, the game-over screen's Hangar button calls `GameState.refund_ledger()` first (the explicit refund rule), and the Hangar's own Back button goes to the world map. The in-mission pause menu (`scenes/hud/pause_menu.tscn`, on `p1_pause`) has Resume, Options, Restart Mission and Quit to Hangar. Quit to Hangar calls `refund_ledger()` first, the same refund rule as game over. Options opens `options_screen.tscn` embedded as an overlay (`embedded = true`, so Back emits `closed` instead of going to the title). The menu won't open while a tutorial prompt already has the tree paused.
- **Dynamically-built menu buttons must explicitly grab focus and set `focus_mode`.** The map screen initially shipped with no default focus on any node, so the pad's confirm button had nothing to activate -- unlike statically-authored menus (`title_screen`, `ship_select`), a screen that builds its interactive controls at runtime (`hangar`, the map) must grab focus on the right one itself once built. Also set `focus_mode = FOCUS_NONE` on anything meant to be unselectable (a locked map node) -- `disabled = true` alone still lets a Button receive pad/keyboard focus, so a generic "confirm whatever's focused" handler could otherwise activate a disabled control.
- **Any modal/overlay that's hidden after a choice must explicitly `grab_focus()` on something afterward** -- Godot clears `gui_get_focus_owner()` when the focused control's ancestor becomes invisible, and it doesn't come back on its own. Hit this in `slot_select`'s delete-confirm overlay (confirming or cancelling a delete left nothing focused, so the pad had nothing to select) and in the map's "Coming soon" overlay. `slot_select` regrabs the relevant row's button; the map regrabs the stored frontier button. Any future overlay/dialog needs the same explicit regrab on close.
- **World map** (`scenes/menus/map_screen.tscn`/`.gd`): `MapNodeData` resource (`id`, `display_name`, `column` 1–7, `lane` `"north"`/`"south"`/`""`, `mission_scene_path`, `map_position`, `label_offset`). Each node is drawn at its real place on the world-map art: `map_position` is where the icon sits, from a projection fitted to the map image, and `label_offset` places the name. London, Paris and the Fjords are nudged apart so their icons don't overlap, and Orbital sits in the Pacific. Moving a node means editing its data, not code — 12 nodes in `data/map/` (London at column 1, five north/south pairs at columns 2–6, Orbital at column 7 laneless), wired via `GameState.all_map_nodes`. Columns 1–4 have a `mission_scene_path` set; every other node shows correct locked/available/completed state but opens a "Coming soon" overlay instead of launching (the rest aren't built yet). A node is the single **frontier** (available to launch fresh) when its `column`/`lane` match `GameState.current_column`/`current_lane`; completed nodes stay clickable for replay (tech only, no progress). Lane choice happens after clearing columns 1, 3 and 5 (`GameState.pending_lane_choice`, blocking overlay on map open) and can switch lanes each time — column 3 inherits column 2's lane, then re-offers a choice, same at 5→6, giving the design doc's "8 possible routes." `GameState.complete_mission()` only advances `current_column` when `is_replay` is false; the map screen sets that flag right before every launch (true for a completed non-frontier node, false for the actual frontier) — this is the mechanism that lets completed missions be replayed for tech without re-advancing.
- **`click_button_by_text` and `find_ui_elements` don't respect Godot's actual visual/input occlusion** — they can find and "click" a button sitting underneath a modal overlay that's genuinely blocking real input. When a modal is up, prefer `simulate_mouse_click` at the target's known screen coordinates (from a prior `find_ui_elements` call, or reasoned from layout), or call `.pressed.emit()` directly via `execute_game_script` to isolate a click-tool quirk from a real signal-wiring bug.
- **A freshly created `class_name` script doesn't register with the live editor process** even after `reload_project` (a filesystem rescan, not the engine-level class re-registration a full editor restart does) — confirmed present in `.godot/global_script_class_cache.cfg` but still unusable by `create_resource`'s type lookup or an `Array[ThatType]`-typed exported property (silently deserializes empty). Workaround: type the exported array as `Array[Resource]` instead (element-level typing in GDScript still works fine, e.g. `for x: ThatType in the_array`), and build/save new instances of the type via `execute_editor_script` (`load(script_path).new()`, `ResourceSaver.save()`) instead of `create_resource`. Also: `get_node_properties`/`get_scene_tree` on a scene already open in an editor tab can show a stale cached view even after the on-disk file is correct and `reload_project` has run — verify via `execute_editor_script` loading the `.tscn` fresh with `load().instantiate()` instead of trusting the inspector-view tools when something looks wrong.
- **`add_node`'s `properties` dict can silently fail to set an object-valued property** (a `Texture2D` on `texture`, for instance) — the call reports success but the property comes back `null` on the next `get_node_properties`. Follow up with an explicit `update_property` for any object-typed property passed to `add_node`, and don't trust the initial call alone.
- **Editing a node that belongs to an *instanced* `PackedScene`, from the parent scene it's instanced into, doesn't persist structurally.** A parent `.tscn` (e.g. `ship_select.tscn`) only stores property *overrides* on an instance (like its exported `ship` field) — adding, moving or deleting one of that instance's internal child nodes from the parent scene's context silently no-ops, with no error. Structural changes to an instanced scene's contents must be made by opening the base scene itself (e.g. `ship_select_entry.tscn`) directly, not the scene it's placed into.
- **`update_property` on a Control's `size` can get silently clamped back down** if it's set in the same batch *before* a `custom_minimum_size` increase — the size gets capped to whatever `custom_minimum_size` still was at the moment of that call. Update `custom_minimum_size` first, then `size` (or just re-issue the `size` update afterward if the order can't be guaranteed).
- **A freshly added `@export` property on a `Resource` script isn't recognized by `edit_resource`** until `reload_project` runs, even when `validate_script` already reports the script compiles cleanly — `edit_resource` returns `"changed": {}` (silently does nothing) rather than an error. Same staleness class as the documented `class_name` caching issue below, but for a plain exported-field addition rather than a `class_name` registration.
- **`edit_resource` on a `Texture2D`-typed property silently writes a raw path string instead of an `ExtResource` reference** if the target PNG hasn't been through `reload_project` yet (brand-new file, no `.import` sibling at call time) — the call reports success and even echoes back what looks like the new value, but the `.tres` on disk gets `portrait = "res://path/to/file.png"` (a String) instead of `portrait = ExtResource("id")`, which breaks the typed field. Re-running `edit_resource` after `reload_project` doesn't fix an already-broken property either — it just re-writes the same bad string, since the resource is already cached in the broken state. The fix is `execute_editor_script` with `ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)` for both the target resource and the texture, assign, then `ResourceSaver.save()` (needs `allow_unsafe_editor_io: true`). Always `reload_project` *before* the first `edit_resource` call on a texture that was just dropped into the project, not after.
- **`execute_editor_script`'s injected code can't declare a nested `func`** (it already runs inside a `run()` wrapper) — use a `var x := func(...):` lambda and `.call(...)` instead.
- **`load()` inside `execute_editor_script` can return a stale `ResourceCache` copy** of a `.tres` that's already been loaded once this editor session (e.g. a mission file read repeatedly during earlier playtesting) — editing the file on disk afterward doesn't invalidate that cache entry, so a `load()` from an editor script can show old data even though the real game (a fresh process via `play_scene`) reads the current file correctly. Use `ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)` to force a fresh read when verifying an edit from `execute_editor_script`, or just verify through an actual `play_scene` run instead.
- **Story screens** (`scenes/menus/briefing_screen.tscn`/`.gd`): a separate system from the in-mission `DialogueEntry`/`DialogueController` (time-triggered, mission-embedded) — `BriefingLine` (`speaker_name`, `portrait`, `portrait_color`, `text`) is a player-advanced sequence for full-screen pre/post-mission briefings. `MissionData.pre_briefing_lines`/`post_briefing_lines` hold the content; `MapNodeData.mission_data` links a map node to its `MissionData` so the map can pull pre-briefing content before launching, and `GameState.find_map_node()` lets the results screen pull post-briefing content after. Data crosses the `change_scene_to_file` boundary via two transient `GameState` fields (`pending_briefing_lines`, `pending_briefing_next_scene`) set right before the scene change — briefing_screen reads them in `_ready()` and clears them on exit. A mission with no briefing content skips the screen entirely (empty array short-circuits straight to the target scene). The column-4 midgame reveal (`GameState.midgame_reveal_shown`, persisted; `midgame_reveal_lines`) is checked and prepended in the map screen's activation handler, column-agnostic so it fires on whichever lane reaches column 4 first — verified via direct `GameState`/method-call manipulation the same way task 6's lane-choice logic was, since no column-4 mission exists yet to click through for real.
- **Settings** (`scripts/autoload/settings.gd`/`.tscn`): CRT filter (`shaders/crt_filter.gdshader`, a scanline + vignette `canvas_item` shader on a `ColorRect` living inside `settings.tscn` itself — since autoloads persist across every scene change, this gives a global overlay without touching every individual scene), screen shake (`scripts/systems/playfield_shake.gd` attached to London's `PlayfieldRoot`, triggered via `get_tree().call_group("playfield_root", "shake")` from `player_ship.gd`'s hull-hit branch — decoupled so any future level's `PlayfieldRoot` just needs the same script attached, no hard node-path coupling), high-contrast bullets (an outline pass in `bullet_manager.gd`'s `_draw_bullet`), and difficulty (three multipliers — `damage_taken_multiplier()`, `shield_recharge_multiplier()`, `focus_refill_delay_multiplier()` — applied in `player_ship.gd`; `GameState.difficulty` mirrors `Settings.difficulty` in `start_new_run()`, called every mission entry). Remapping is scoped to the six button-like actions (not `move`/`aim`, which are stick/mouse-bound); `Settings.REMAPPABLE_ACTIONS` names them, `remap_action()`/`reset_action()` mutate `InputMap` directly. Saved to `user://settings.cfg` via `ConfigFile`, separate from `SaveManager`'s per-slot saves.
- **An autoload can't safely `@onready`-cache another autoload declared later in `project.godot`'s `[autoload]` list** — each autoload's `_ready()` runs fully before the next one is even added to the tree, so a `get_node("/root/X")` resolved during an *earlier* autoload's `@onready` fails if `X` loads later. Hit this with `BulletManager` (declared first) trying to cache `Settings` (declared last, matching its documented position) — fixed by calling `get_node("/root/Settings")` fresh inside `_draw()` instead of caching it, which is safe since `_draw()` only ever runs long after every autoload exists. A scene-tree node (not itself an autoload) caching a `Settings` reference via `@onready` is always safe regardless of autoload order, since scenes only load after all autoloads are fully initialized.
- **This project's existing key bindings in `project.godot` set `keycode`, not `physical_keycode`** (`InputEventKey.physical_keycode` is `0` on all of them) — reading `.physical_keycode` alone to display a binding (e.g. for a remap UI) silently returns an empty string for every pre-authored binding, even though it correctly picks up a *freshly captured* live key press (those always populate `physical_keycode`). Check `physical_keycode` first, fall back to `keycode` if it's `0`.
- **Boss patterns and London tuning:** bosses can fire a second pattern alongside the main one (`BossData.secondary_pattern` / `phase_2_secondary_pattern`), and `EnemyBase` runs it on its own timer and seeded RNG. After the first playtest (too easy, no lives lost):
  - The Tower Bridge boss has 450 hull.
- **Boss signatures:** each final boss has its own pattern set, built from the extra `BulletPatternData` options: `emitter_offsets` (fire from turret positions on the art), `layers` / `layer_speed_step` (stacked waves), `sweep_degrees` / `sweep_period_bursts` (a swinging angle) and `speed_jitter` (scattered shards). All of them are seeded, so patterns stay deterministic.
  - **Tower Bridge:** twin-tower aimed volleys plus a sweeping curtain from the core. Phase 2: layered tower volleys plus a rotating ring.
  - **Seine siphon:** two sweeping water jets from the tanks plus layered droplet rain. Phase 2: counter-rotating spirals that form a lattice.
  - **Glacier drill:** ice-shard sprays from the drill arms plus a spinning pinwheel from the drill. Phase 2: a shard storm plus slow layered ice walls.
  - The Sentinel mid-boss keeps its ring patterns.
- **Special meter:** every mission starts with 3 charges (`ShipData.special_charges_at_start`, capped at `special_charge_max`). Recharging is slow: each point of damage dealt adds 0.0012 of a charge and each kill adds 0.0048 (`ShipData` defaults), which works out to a handful of charges per mission plus pickups. The first values (0.05 and 0.25) refilled almost constantly. The Special Meter Rate upgrade adds 0.0003 per level.
  - The mid-boss has 150 hull.
  - From 2:30, drones and swarmers switch to the `*_late` pattern variants (spreads with 15% faster bullets), and the last minute has 22 extra mirrored spawns (`london_late_extra_*.tres`).
  - Shields wait 4s before recharging, then recharge at 1.5/s (`ShipData` defaults).
- **Mouse aim crosshair:** `scenes/hud/crosshair.tscn`, a CanvasLayer at layer 20, is instanced in each level. It hides the OS cursor during missions and draws an 11×11 pixel crosshair at the mouse position. It hides itself when the pad is used, and gives the OS cursor back while paused or after leaving the level. New levels need both this and the pause menu instanced.
- **Contact damage:** colliding with an enemy damages the player (`EnemyData.contact_damage`, default 1.0, 0.5s cooldown), through the same `take_hit()` as bullets. Enemies take no damage from it.
- **Specials persist for their full duration:** the shape re-applies every physics frame for `special_duration` and tracks the player's position, rather than firing once at cast time.
- **Pilots:** Dash (Interceptor), Bucky (Striker), Max (Guardian), Tammy (Vanguard). Commander: Steel. Held in `ShipData.pilot_name` / `radio_intro` and the dialogue `.tres` files, never hard-coded.
- **Music:** placeholder synthesised loops, wired through `MissionData.tutorial_music` / `stage_music` and `BossData.music` / `music_phase2`.
- **Ship-select real art:** `ShipData` gained two `Texture2D` fields — `select_art` (72×72, `art/sprites/ship_select/`) and `icon_sprite` (24×24, `art/sprites/player_ships/`). `ship_select_entry.tscn`'s old `Swatch` `ColorRect` is kept as a transparent sizing wrapper around a new child `TextureRect` ("Art") rather than replaced, since a `ColorRect` can't be retyped in place — same pattern used for every other placeholder→art swap this pass (title `Backdrop`, HUD panel `ColorRect`s). Below the name/pilot/traits text, each entry also shows the 24×24 `icon_sprite` plus three stat bars (speed/shield/hull), normalized in `ship_select.gd` against the max across all four ships (not a fixed scale) so the bars are only meaningful relative to each other. `TraitsLabel` has a fixed `custom_minimum_size.y` (2 lines' worth) regardless of actual wrapped line count — without it, ships whose trait text wraps to a different number of lines (`"Slower, big shield"` vs `"High power"`) push everything below by a different amount per column, breaking the icon/stat-row alignment across entries.
- **In-flight player sprite:** `player_ship.gd`'s `_ready()` slices `data.bank_sheet` (5 frames) into the five `bank_frame_*` slots, and falls back to `data.icon_sprite` in every slot when no sheet is set. The `Sprite` node must stay at scale 1. It was once left at 1.5 from the placeholder era, which drew the 24px ship at 36px with uneven pixels.
- **Player sprite is clamped to the playfield, not just the hitbox.** `_process_movement`'s bounds clamp used to constrain only the ship's center (effectively the tiny hitbox) to `Playfield.rect`, so up to half the visible sprite could overlap the HUD side panels or go off the top/bottom of the screen. Fixed with `_sprite_half_extents` (read from the actual `$Sprite.texture.get_size()` at `_ready()`, not a hardcoded number, so it stays correct as real art changes the sprite's dimensions) insetting the clamp bounds. The gameplay hitbox itself (`normal_hitbox_radius`) is untouched — this only affects where the visible sprite is allowed to sit.
- **`Settings` was silently losing joypad bindings.** `save_settings()`/`load_settings()` only persisted `events[0]` per remappable action (`REMAPPABLE_ACTIONS`), instead of the full event array. Every remappable action defaults to two events — a keyboard/mouse one first, a joypad one second — so the pad binding was dropped from `user://settings.cfg` the first time settings were ever saved for *any* reason (toggling CRT filter, difficulty, not just an actual remap), with no error and no code touching remapping at all. Fixed to persist/restore the full array; `load_settings()` also tolerates the old single-event format already written to disk by the bug (wraps it in an array) so existing corrupted `settings.cfg` files don't crash, though the lost binding itself can't be recovered from a file that already lost it — clearing the `[bindings]` section by hand restores the project defaults.
- **HUD elements can show stale/default values for one frame at mission start.** `HUD.bind_player()` connects to `player_ship.gd`'s signals (`shield_changed`, `hull_changed`, `focus_changed`, `ordnance_ammo_changed`, etc.) *after* the player node's own `_ready()` has already fired its initial emit of each — `PlayerShip` readies before `HUD` in `london.gd`'s child order, so the very first emit has no listener yet. Fixed the same way the pre-existing `special_charges`/squad-selection sync already worked around it: `bind_player()` now explicitly re-reads and pushes the current state for shield, hull, focus, ordnance and lives right after connecting, rather than waiting for the next real change. Needed a new `player_ship.gd:get_focus_meter()` getter since `_focus_meter` is private.
- **HUD shield/hull/focus bars are real art, tiled by the engine, not custom-drawn.** Each is a stock `ProgressBar` whose "fill" style is a `StyleBoxTexture` (`themes/shield_bar_fill.tres`, `hull_bar_fill.tres`, `focus_bar_fill.tres`) pointed at a 5×10 tile with `axis_stretch_horizontal = STRETCH_TILE`. The 1px gap between repeated tiles is baked into the tile art itself (column 4 of the 5 is fully transparent) rather than handled in code — no custom drawing, no gap-spacing logic. All three bars had to move out of the `LeftPanel` `VBoxContainer` into `LeftPanelBg` (a plain `ColorRect`) since a `Container` continuously re-asserts its children's position/size, making pixel-exact art-matched placement impossible while a node stays inside one; their exact coordinates (shield 46,29 / hull 46,58 / focus 46,87, all 65×10 for a 13-tile track) came from pixel-scanning a reference mockup (`art/reference/panel_left_ref.png`) against the panel art rather than guessing. The remaining `LeftPanel` labels (now just Ordnance/Tech/Score/Chain, `LivesLabel` hidden — see below) were repositioned lower each time a bar left the container so they stop overlapping.
- **Lives are a single digit, not badges.** The original 3-badge `player_lives.png` design was replaced with a numeric display: `ui_0.png`–`ui_9.png` (23×40 each, one full digit sheet) assigned to `HUD.digit_textures`, and `HUD._update_lives_digit()` swaps `LivesDigit`'s texture to match `lives_remaining` (clamped to the sheet's range) and re-centers it at `lives_digit_box_center_x`/`lives_digit_box_top`. Called from both the bind-order-fix initial sync and `_on_life_lost`. `LivesLabel`'s text is still hidden (`visible = false`), not deleted, for the same reason as before.
- **Ordnance is shown as a 6-badge grid, not a count label.** `OrdnanceBadgeR1Left/Mid/Right` and `OrdnanceBadgeR2Left/Mid/Right` (36×29 each, `player_ordinance.png`) sit in a fixed 2×3 grid in `LeftPanelBg`; `HUD._update_ordnance_badges()` shows badge *i* only while `i < current`, called from `_on_ordnance_ammo_changed`. `OrdnanceData.starting_ammo` is 6 (raised from 5) specifically to fill the grid evenly — changing it away from a multiple of 3 will leave a visibly uneven last row. The `LeftPanel` `VBoxContainer` (Tech/Score/Chain labels) originally started right on top of this badge grid; it now sits at y 180–236, below the badges and above the lives digit.
- **HUD right panel:** the special meter (`SpecialBar`, blue `special_bar_fill.tres`), three `SpecialCharge` icons shown per charge held, and a SQUAD box with the armed squad-mate's `icon_sprite` and pilot name (`SquadIcon` / `SquadName`). The old `RightPanel` text labels are hidden but still updated. The left panel's Tech/Score/Chain labels use dark `2e222f` text on the light panel.
- **HUD panel backgrounds** (`panel_left.png`, `panel_right.png`, both 140×360) use the same non-destructive swap pattern as ship-select art: the original `LeftPanelBg`/`RightPanelBg` `ColorRect`s stay in the tree as transparent sizing wrappers, with a child `TextureRect` ("Art") added for the actual image, since a `ColorRect` can't be retyped into a `TextureRect` in place.
- **Ship movement has real momentum, not instant velocity.** `player_ship.gd:_process_movement()` smooths `_velocity` toward the stick's `move_speed`-scaled target with `move_toward(target, move_acceleration * delta)`, rather than setting velocity directly. `move_acceleration` is `2000.0` on all four ships (`data/ships/*.tres`, overriding `ShipData`'s `500.0` default) — the 500 default gave a 0.3–0.4s ramp to top speed that read as heavy/unresponsive; 2000 reaches top speed in ~0.05–0.1s. Deceleration uses the same value, so it's symmetric.
- **Portrait art:** two different wiring patterns depending on how a character speaks. `DialogueEntry` (covers `TutorialBeat`, which extends it) and `BriefingLine` each gained a `portrait: Texture2D` field alongside the existing `portrait_color`; a line's author picks whichever of a character's expressions fits that line, the same way `text` is authored per line — there's no expression-enum or runtime selection logic. Steel has 4 expressions (`art/sprites/portraits/steel_*.png`) hand-assigned across all 11 of his static `.tres` lines (intro dialogue, 3 pre-briefing, 5 tutorial beats, 2 post-briefing) by tone; `steel_hurt` is imported but unused — no damage-reaction line exists yet. The four ship pilots (Dash/Bucky/Max/Tammy) only ever speak once each, in the tutorial's dynamically-built squad-radio beat (`tutorial_sequencer.gd:_process_squad()`), which is built from `ShipData` at runtime rather than a static `.tres` — so instead of per-line fields, `ShipData` gained a single `portrait: Texture2D` (same pattern as `select_art`/`icon_sprite`), and `_process_squad()` copies `_current_squad_ship.portrait` onto the beat it builds. Each pilot has 3 unused expressions in reserve. The in-mission dialogue bar (`dialogue_box.tscn`) had to grow from 56px to 80px tall, and its portrait slot from 44×44 to 64×64, to fit the art at native size without fractional scaling (forbidden by the art-pass rules); the full-screen briefing's `PortraitBox` (`briefing_screen.tscn`) was already exactly 64×64. Both use the non-destructive `ColorRect`-wrapper-plus-child-`TextureRect`("Art") pattern. Real portraits sit on a palette backdrop (`portrait_backdrop_color`, `3e3546`) on both screens. The per-line `portrait_color` only shows when a line has no portrait texture.

## Hard rules

These are not negotiable.

1. **Scenes are real `.tscn` files.** Build them with nodes in the scene tree through the Godot MCP Pro editor tools, so they can be seen and edited in the editor. Don't build node hierarchies in code with `add_child()` when the node belongs in a scene. Scripts are for behaviour only.
2. **Tuning values are `@export` variables**, so they can be adjusted in the Inspector. That includes speeds, fire rates, health, cooldowns and sizes. Don't use magic numbers in logic.
3. **Game data lives in `.tres` Resources** (custom `Resource` classes): ships, enemies, bullet patterns, upgrades, missions, pickups and dialogue. Code reads the data; it doesn't define it.
4. **Pixel-perfect settings are fixed.** Don't change them:
   - Viewport 640×360
   - Stretch mode `viewport`, scale mode `integer`
   - Default texture filter `Nearest`
   - Renderer `gl_compatibility`
5. **Use static typing everywhere in GDScript.** Type every variable, parameter and return value (`var speed: float = 120.0`, `func fire(dir: Vector2) -> void:`). Use `class_name` for reusable scripts.
6. **Pool bullets and spawn them in code.** This is the one exception to rule 1. Never `instantiate()` or `queue_free()` bullets during play. A bullet manager owns the pools, and patterns request bullets from it. Scale this for thousands of bullets on screen.
7. **Lock to 60fps.** Gameplay logic runs in `_physics_process` at 60 ticks. Bullet patterns must be deterministic, identical on every run and at every difficulty. If randomness is needed, use a seeded `RandomNumberGenerator`, never `randf()`.

## Screen layout

- **Playfield:** a centred playfield of about 360×360 inside the 640×360 screen, with HUD side panels about 140px wide.
- **No SubViewport.** It didn't display under the Compatibility renderer.
- **`PlayfieldRoot`:** all gameplay (player, enemies, bullets, pickups, backgrounds) lives under a `Node2D` called `PlayfieldRoot`, offset to the playfield position. Screen shake moves `PlayfieldRoot` only.
- **`Playfield` helper:** a shared helper holds the playfield rectangle. Use it for bounds checks, for converting relative spawn positions (0–1 across the playfield) to world positions, and for mouse-aim conversion. **Never hard-code playfield pixel positions.**
- **Spawn positions** in timeline `.tres` files are stored as relative values (0–1).
- **HUD:** a `CanvasLayer` above the playfield, with **opaque** side panels so gameplay overdraw at the edges is hidden. The panels hold the pilot portrait, shield and hull, special charges and selected squad-mate, focus meter, ordnance and ammo, score and multiplier, and lives.
- **Dialogue:** the portrait sits in a side panel and the text runs along the bottom of the playfield.
- **Menus, hangar and map** use the full 640×360 screen, not the playfield.
- **Test range:** uses the same layout.

## Sprite sizes

Full detail is in `docs/art-specs.md`. The essentials:

| Object | Size |
|---|---|
| Player ships | about 24×24 |
| Player hitbox | 3–4px at the ship's centre, the same on all four ships |
| Small enemies | 16–24 |
| Mid-bosses | about 64 |
| Bosses | 128–200 |
| Bullets | 6×6 (player and enemy), 8×8 (boss) |
| Portraits | 64×64 |
| Pickups | 12×12 (alien tech 6×6 / 8×8) |
| Explosions | 16 / 32 / 64 |

## Fonts

- **Default font:** Press Start 2P (`art/fonts/PressStart2P-Regular.ttf`, SIL OFL 1.1 — licence file kept alongside it), wired project-wide via `themes/main_theme.tres` (`gui/theme/custom`). Antialiasing, hinting and subpixel positioning are disabled on import for a crisp pixel look — keep new pixel fonts imported the same way.
- **Sizes:** 8px (the font's native pixel grid) by default. Use 16px for screen titles and main-menu buttons, and 32px for single big characters. Only multiples of 8 stay crisp. Speaker names in the dialogue box and briefings are 8px gold. Labels over busy art get a 2px `2e222f` outline.
- To swap in a different pixel font later, replace the `.ttf` and re-point `default_font` on `themes/main_theme.tres`.

## Project settings

These are already set. If any need checking or changing, use `get_project_settings` or `set_project_setting`.

- `display/window/size/viewport_width = 640`, `viewport_height = 360`
- Default window size 1920×1080 (3×)
- `physics/common/physics_ticks_per_second = 60`
- `application/run/max_fps = 60`, with V-Sync on
- `rendering/renderer/rendering_method = "gl_compatibility"`

## Folder layout

```
res://
  addons/            # Godot MCP Pro plugin and other editor plugins (ask before adding any)
  art/
    source/          # .aseprite working files
    sprites/         # exported PNGs (real art)
    placeholder/     # asset-pack placeholders, one folder per pack + source/licence note
    fonts/           # pixel fonts (Press Start 2P, OFL licensed)
    palette/         # the game palette (resurrect-64.hex, plus a .png swatch)
    reference/       # layout reference mockups (not shipped art)
  audio/
    music/           # OGG files with loop points (currently placeholder synthesized loops)
    sfx/             # jsfxr / ChipTone exports (none yet)
  data/              # .tres Resources: ships/, enemies/, patterns/, upgrades/, missions/, dialogue/
  scenes/
    player/  enemies/  bosses/  bullets/  pickups/  specials/  effects/
    levels/  ui/  hud/  menus/
  scripts/
    autoload/        # global singletons
    resources/       # custom Resource class definitions
    systems/         # bullet manager, spawner, playfield helper, scoring, etc.
  themes/            # global Theme resources: font, button/panel frame styles, bar fills
  shaders/           # crt_filter, silhouette_flash (palette-true hit flash)
  tools/             # dev scripts outside Godot (.gdignore): check_palette.py
  docs/
    design-summary.md
    art-specs.md
```

Scripts that belong to a specific scene sit next to that scene. `scripts/` is for shared code only.

## Naming conventions

- Files and folders use `snake_case`: `player_ship.tscn`, `player_ship.gd`.
- Class names use `PascalCase`; variables and functions use `snake_case`; constants use `UPPER_SNAKE_CASE`.
- Signals are named in the past tense: `hull_depleted`, `special_fired`, `enemy_destroyed`.
- Private members start with `_`.

## Input actions

Every action has a player prefix so that local co-op works later. Only P1 is bound for now.

`p1_move_left/right/up/down`, `p1_aim_left/right/up/down`, `p1_focus`, `p1_squad_prev`, `p1_squad_next`, `p1_special`, `p1_ordnance`, `p1_pause`

| Action | Pad | Keyboard/mouse |
|---|---|---|
| move | left stick | WASD |
| aim | right stick (releasing it stops firing) | mouse direction plus left click |
| focus | LT | Shift |
| squad_prev / squad_next | LB / RB | Q / E |
| special | RT | right click |
| ordnance | A | Space |
| pause | Start | Esc |

**Always code against actions, never against specific keys or buttons.** Player code must accept a player index; never hard-code "player 1". Menus, the hangar and the map must be fully usable with the pad alone, as well as with keyboard and mouse.

## Collision layers

1. player (a small hitbox only, not the sprite)
2. player_bullets
3. enemies
4. enemy_bullets
5. pickups
6. specials (the area-of-effect shapes)

## Autoloads

- `GameState` **(exists)**: current run, lives, selected ship — extended in milestone 3 with map position, tech, upgrades and the purchase ledger.
- `AudioManager` **(music implemented)**: `scripts/autoload/audio_manager.tscn`, one `AudioStreamPlayer` set to `PROCESS_MODE_ALWAYS` (music must keep playing through tutorial-beat pauses). Tracks are data-driven — `MissionData.tutorial_music` / `stage_music`, `BossData.music` / `music_phase2` — never hard-coded paths. Sound effects and Sound Test unlocks still to come.
- `SaveManager` **(implemented)**: `scripts/autoload/save_manager.tscn`, 3 slots, saving only after a completed mission.
- `Settings` **(implemented)**: `scripts/autoload/settings.tscn`, last in autoload order (documented order, matches its position in `project.godot`). CRT filter, screen shake, remapping, high-contrast bullets, difficulty. Saved to `user://settings.cfg` via `ConfigFile` (not `SaveManager`'s per-slot `.tres` files) — `ConfigFile` correctly serializes `InputEvent` objects for remapping, the same way `project.godot` itself already stores them.

## Using Godot MCP Pro

The Godot editor is open and connected through Godot MCP Pro. Use its tools in preference to editing files by hand.

- **Editor tools versus runtime tools.** Editor tools (scene, node, script, project, resource, animation, shader and similar) work on the scene open in the editor and are always available. Runtime tools (game state, input simulation, capture and recording, testing, game screenshots) **only work after `play_scene`**, and they fail otherwise. Always finish with `stop_scene`.
- **Building a scene:** `create_scene` or `open_scene`, then `add_node` or `batch_add_nodes`, then `create_script` + `attach_script`, then `save_scene`.
- **Tuning values:** set node properties in the Inspector with `update_property` rather than in code. Use a script only when the value must change at runtime.
- **Project settings and input actions:** use `set_project_setting` and `set_input_action`. **Never edit `project.godot` directly**, because the editor overwrites it.
- **Keep the editor and disk in sync.** Change scenes and resources through the editor tools, not by editing .tscn/.tres files directly. Always call `save_scene` after scene changes. If a file had to be edited on disk, call `reload_project` afterwards.
- **Testing gameplay:** `play_scene`, then drive input with **`simulate_action` using the `p1_` action names** (not raw keys), then check the result with `get_game_screenshot`, `capture_frames` or `monitor_properties`, then `stop_scene`. Never leave a game window running. For the bullet manager, use `run_stress_test` and `get_performance_monitors` to check the 60fps target.
- **Testing menus and saves:** use `find_ui_elements`, `click_button_by_text` and `assert_node_state`. Save/load must be tested by writing a save, restarting the game and checking the values survived — not just by reading them back in the same session.
- **After script changes:** run `validate_script`. If a new script doesn't take effect, run `reload_project`.
- **Checking for errors:** use `get_editor_errors` and `get_output_log`.
- **Pitfalls:**
  - Property values are passed as strings, for example `"Vector2(100, 200)"` or `"Color(1, 0, 0, 1)"`.
  - Give for-loop variables explicit types: `for enemy: Enemy in enemies`.
  - `compare_screenshots` takes file paths (`user://...`), not image data.
  - With `simulate_key`, use short durations (0.3–0.5s) to avoid overshooting.
  - `execute_game_script` doesn't allow a function inside a function, and uses `.get("property")` for safe access.
- **If "Godot editor is not connected" appears:** a stale `node.exe` is probably holding the port. Tell the developer instead of retrying repeatedly.
- **At the end of each task,** tell the developer which scene to run to see the change (F5 main scene or F6 a specific scene).

## Workflow

- **Before starting a task,** check `docs/design-summary.md` and the current milestone above.
- **Plan first.** For anything larger than a small fix, propose a plan and wait for approval before building.
- **Do the work in the editor** through Godot MCP Pro wherever possible: create scenes, add nodes, set properties.
- **Before calling a task done,** run the project through MCP, read the output and error log, and fix any errors or warnings. Take a screenshot when the change is visual.
- **Don't break London.** It's the reference mission. After any change to shared systems (player, HUD, GameState, flow), play London far enough to confirm it still works.
- **Save-data changes:** when the save format changes, either migrate old saves or bump a version number and say clearly that old saves will be reset.
- **If you hit a blocker,** stop and report it with options rather than working around a hard rule.
- **Report bugs you notice** that are outside the current task, and don't fix them without approval.
- **Keep changes small and focused.** One feature per commit, with a clear message (`Add focus meter to player`).
- **At the end of a session,** when asked, update the "Current milestone" and "Art" sections (and `docs/art-specs.md` if art changed): mark finished tasks **[done]** and note where work stopped.
- **Git:**
  - Commit to the local repo.
  - The remote is GitHub.
  - Never commit `.godot/` (the import cache) or exported builds. `.gitignore` handles `.godot/`.
  - **Do** commit `*.import` files. In Godot 4 they hold each asset's import settings (such as pixel-art filtering), and the project needs them.
  - Ask before force-pushing or rewriting history.
- **Ask first** before adding plugins or addons, changing any hard rule or project setting, or making a design decision the summary doesn't cover.
- **Explain as you go.** The developer knows programming but is still learning Godot, so briefly explain Godot-specific choices (why a node type, why a signal) when you make them.
- **Placeholders:** for new content without art yet, use `ColorRect`, simple shapes or the asset-pack placeholders, sized to `docs/art-specs.md`. Keep placeholder colours on the palette too.

## Performance notes

- The retro laptop is the minimum spec, so test bullet-heavy features against it.
- Avoid giving every bullet its own `Area2D` if profiling shows a cost. Moving bullets in the manager and doing simple circle-versus-hitbox checks against the player is acceptable.
- Don't create objects every frame inside hot loops.
