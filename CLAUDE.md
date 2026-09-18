# CLAUDE.md — Terra Intercept

Terra Intercept is a 2D pixel-art vertical-scrolling bullet hell with twin-stick controls, built in Godot. It's a hobby project with a 90s arcade feel.

**The full design lives in `docs/design-summary.md`. Read it before building any gameplay feature.** Art dimensions live in `docs/art-specs.md`. Don't invent design decisions. If something isn't covered there or is unclear, ask before implementing.

## Current milestone

Milestone 1 (vertical slice) — complete (tag `vertical-slice`).
Milestone 2a (core systems) — complete (tag `milestone-2a`).
Milestone 2b (London, mission 1) — complete (tag `milestone-2b`).

**Now: Milestone 3 (campaign structure), with the 2c art pass running alongside it.**

Milestone 3 builds the frame around the mission that already works: saves, the hangar, upgrades, the world map and the story screens. Real art arrives piece by piece while this happens, so 2c is no longer a separate milestone — it's a rolling task list (see "Rolling art pass" below).

Build in this order, one task at a time, committed separately. Mark each **[done]** when finished and committed.

1. **Art pipeline. [done]** Set up the import path for real art before any lands: folder convention, sprite-sheet format, and an import preset with nearest filtering and no mipmaps. Verify it with one real asset end to end (import → animation → in-game). Record what you set up in this file under "Rolling art pass".
2. **SaveManager and save slots. [done]** 3 slots. A save holds: selected ship, map position, banked alien tech, upgrades owned, the purchase ledger (see task 4), mission results and high scores. Saving happens **only** on mission completion. Add a slot-select screen with create, continue and delete.
3. **Run state. [done]** Extend `GameState` to hold everything a run needs so the hangar and map can read it: current column, lane, completed missions, tech, upgrades, and difficulty.
4. **Upgrades. [done]** Upgrade definitions in `.tres`: id, name, description, cost, the stat it changes, its maximum level, and the map column that unlocks it. Apply them to player stats at mission start. Keep a **purchase ledger** of what was bought since the last completed mission, so a return to the hangar after a game over refunds exactly those purchases and nothing earlier.
5. **Hangar screen.** Spend alien tech on the available upgrades, show what's locked and why ("unlocks at column 3"), and handle the refund rule from task 4. Reachable from the map, and after a game over.
6. **World map.** 6 columns in two lanes, with a lane choice after columns 1, 3 and 5, converging on mission 7. Show completed, available and locked missions. Cleared missions can be replayed for tech. The map position is saved.
7. **Story screens.** Pre- and post-mission briefings using the existing portrait-and-text-box system, driven by dialogue `.tres` files. Mission-specific briefings, plus the column-4 midgame reveal, which must work on every route.
8. **Full flow.** Title → slot select → ship select (new run only) → map → briefing → mission → results → post-briefing → hangar → map. Game over offers restart or hangar, with the refund rule applied.
9. **Settings.** The `Settings` autoload and an options screen: CRT filter, screen shake, button remapping, high-contrast bullets, difficulty (Easy/Normal). Settings save separately from run saves.

**Not yet:** sound effects and the Sound Test, missions 2–13, co-op. Ask before starting any of these.

Every milestone must run at a steady 60fps on the retro laptop (i7-1165G7 / Iris Xe).

## Rolling art pass (former milestone 2c)

Real art arrives piece by piece while milestone 3 is being built.

- **Never interrupt the current task** to swap art in. Finish the task, commit, then do the art swap as its own small task and commit.
- **Follow `docs/art-specs.md`** for every size. If an incoming asset doesn't match the spec, say so and ask rather than rescaling: pixel art must never be scaled by fractions.
- **Hitboxes and collision shapes don't change** when art is swapped in. A bigger sprite doesn't mean a bigger hitbox.
- **Palette:** the fixed 32–48 colour palette, with bullet colours reserved and never used in backgrounds.
- **Placeholder art from asset packs** lives in `art/placeholder/<pack-name>/`, each folder with a note on its source and licence. It never mixes with the real art in `art/sprites/`.

**Pipeline setup (task 1, done):**
- `rendering/textures/canvas_textures/default_texture_filter` confirmed at Nearest project-wide (was already correct).
- `importer_defaults/texture` preset added: no mipmaps, lossless compress, no 3D VRAM compress — locks in correct settings for future imports instead of relying on Godot's stock defaults holding.
- The SHMUPED placeholder pack moved from `art/sprites/placeholder/` to `art/placeholder/shumped-asset-pack/`, with a source/licence note, to match the folder convention.
- **Animation convention for real art:** `AnimatedSprite2D` + a `SpriteFrames` resource, built from a grid-sliced sheet (uniform frame size, per `docs/art-specs.md`), not hand-written per-frame `AtlasTexture` `.tres` files. Proved mechanically (sheet → frames → animated node, playing) in a throwaway scene, then removed — no real asset was available yet to run the full import → animation → in-game proof, so that step is still owed once the first real asset lands.
- The existing placeholder player-ship animation (5 separate `AtlasTexture` resources cycled by script, from the 2025-09-17 commit) was left as-is — out of scope for task 1, and changing it would be an art-swap task of its own.

Swap-in checklist, updated as art lands (all still placeholder unless marked):

- [ ] Player ships (4) with banking frames
- [ ] Bullets and ordnance
- [ ] Enemies: drone, swarmer, lander pod
- [ ] Mid-boss
- [ ] Tower Bridge boss
- [ ] Thames and London backgrounds
- [ ] Pickups and alien tech
- [ ] Explosions and special effects
- [ ] Portraits: Dash, Bucky, Max, Tammy, Steel
- [ ] HUD panel frames and icons
- [ ] Menu, hangar and map screens

## What already exists

Context for anything built from here on.

- **London** runs end to end: a three-section mission (tutorial / Thames run / boss) with marker-based restarts, the non-lethal tutorial, skip-tutorial, drone / swarmer / lander pod, a reusable mid-boss, the two-phase Tower Bridge boss, and the title → slot select → ship select (new run only) → London → results → title flow.
- **Saves:** `SaveManager` autoload, 3 slots at `user://saves/slot_N.tres`, holding a `SaveData` resource (`scripts/resources/save_data.gd`). Written only from `GameState.mission_completed` — Create/Continue never touch disk. Slot identity keys off `ShipData.ship_name` (no dedicated ship id exists) and mission results/high scores key off `GameState.current_mission_name` (set per-level, e.g. `"London"` in `london.gd`). Purchase ledger keys off `{id, cost}` records, see the Upgrades bullet below.
- **Run state:** `GameState` holds persistent run fields (`current_column`, `current_lane`, `completed_missions`, `banked_tech`, `upgrades_owned`, `purchase_ledger`, `difficulty`) separate from per-mission fields (`mission_tech`, `score`, etc.) that `start_new_run()` resets each mission. `complete_mission()` banks `mission_tech` into `banked_tech`, records the mission as completed (no duplicates on replay), and clears `purchase_ledger` (locking in purchases). `SaveManager` mirrors all of these to/from `SaveData` on continue/complete, and `begin_new_run()` resets them all for a fresh run. `difficulty` is a placeholder default ("Normal") until the `Settings` autoload (task 9) exists as its real source — GameState will mirror it, not own it. When typing a `GameState`/`SaveManager` reference as plain `Node` (no `class_name` on either), an untyped `[]`/`{}` literal assigned to a typed-array/dictionary property fails at runtime through the dynamic `set()` path — use `.duplicate()` off an existing typed value, or an explicit `as Array[T]` cast.
- **Upgrades:** `UpgradeData` resource (`scripts/resources/upgrade_data.gd`) — `id`, `upgrade_name`, `description`, `cost`, `stat_name`, `value_per_level`, `max_level`, `unlock_column`. Three examples in `data/upgrades/` (more hull, stronger shields, special meter rate), wired via `GameState.all_upgrades`. `GameState.purchase_upgrade(id)` validates cost/max-level/column-unlock, deducts `banked_tech`, and records `{id, cost}` in `purchase_ledger`; `refund_ledger()` reverses it exactly. Applied at mission start in `player_ship.gd`: `data` is duplicated (`data.duplicate()`) before any upgrade is added, so the shared authored `ShipData` `.tres` is never mutated.
- **A freshly created `class_name` script doesn't register with the live editor process** even after `reload_project` (a filesystem rescan, not the engine-level class re-registration a full editor restart does) — confirmed present in `.godot/global_script_class_cache.cfg` but still unusable by `create_resource`'s type lookup or an `Array[ThatType]`-typed exported property (silently deserializes empty). Workaround: type the exported array as `Array[Resource]` instead (element-level typing in GDScript still works fine, e.g. `for x: ThatType in the_array`), and build/save new instances of the type via `execute_editor_script` (`load(script_path).new()`, `ResourceSaver.save()`) instead of `create_resource`. Also: `get_node_properties`/`get_scene_tree` on a scene already open in an editor tab can show a stale cached view even after the on-disk file is correct and `reload_project` has run — verify via `execute_editor_script` loading the `.tscn` fresh with `load().instantiate()` instead of trusting the inspector-view tools when something looks wrong.
- **Contact damage:** colliding with an enemy damages the player (`EnemyData.contact_damage`, default 1.0, 0.5s cooldown), through the same `take_hit()` as bullets. Enemies take no damage from it.
- **Specials persist for their full duration:** the shape re-applies every physics frame for `special_duration` and tracks the player's position, rather than firing once at cast time.
- **Pilots:** Dash (Interceptor), Bucky (Striker), Max (Guardian), Tammy (Vanguard). Commander: Steel. Held in `ShipData.pilot_name` / `radio_intro` and the dialogue `.tres` files, never hard-coded.
- **Music:** placeholder synthesised loops, wired through `MissionData.tutorial_music` / `stage_music` and `BossData.music` / `music_phase2`.

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

Full detail is in `docs/art-specs.md`. The essentials, which apply to placeholders too:

| Object | Size |
|---|---|
| Player ships | about 24×24 |
| Player hitbox | 3–4px at the ship's centre, the same on all four ships |
| Small enemies | 16–24 |
| Mid-bosses | about 64 |
| Bosses | 128–200 |
| Bullets | 4–8 |
| Portraits | 64×64 |
| Pickups | 12×12 |

## Fonts

- **Default font:** Press Start 2P (`art/fonts/PressStart2P-Regular.ttf`, SIL OFL 1.1 — licence file kept alongside it), wired project-wide via `themes/main_theme.tres` (`gui/theme/custom`). Antialiasing, hinting and subpixel positioning are disabled on import for a crisp pixel look — keep new pixel fonts imported the same way.
- **Default size:** 8px, the font's native pixel grid. 16px was too wide for the ~140px HUD side panels. The dialogue box overrides to 9 (speaker) / 8 (text).
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
  audio/
    music/           # OGG files with loop points (currently placeholder synthesized loops)
    sfx/             # jsfxr / ChipTone exports (none yet)
  data/              # .tres Resources: ships/, enemies/, patterns/, upgrades/, missions/, dialogue/
  scenes/
    player/  enemies/  bosses/  bullets/  pickups/  specials/
    levels/  ui/  hud/  menus/
  scripts/
    autoload/        # global singletons
    resources/       # custom Resource class definitions
    systems/         # bullet manager, spawner, playfield helper, scoring, etc.
  themes/            # global Theme resources (default font/size)
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
- `Settings` **(milestone 3, task 9)**: CRT filter, screen shake, remapping, high-contrast bullets, difficulty. Saved separately from run saves.

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
- **At the end of a session,** when asked, update the "Current milestone" and "Rolling art pass" sections: mark finished tasks **[done]** and note where work stopped.
- **Git:**
  - Commit to the local repo.
  - The remote is GitHub.
  - Never commit `.godot/` (the import cache) or exported builds. `.gitignore` handles `.godot/`.
  - **Do** commit `*.import` files. In Godot 4 they hold each asset's import settings (such as pixel-art filtering), and the project needs them.
  - Ask before force-pushing or rewriting history.
- **Ask first** before adding plugins or addons, changing any hard rule or project setting, or making a design decision the summary doesn't cover.
- **Explain as you go.** The developer knows programming but is still learning Godot, so briefly explain Godot-specific choices (why a node type, why a signal) when you make them.
- **Placeholders:** use `ColorRect`, simple shapes, or the asset-pack placeholders until real art arrives, sized to `docs/art-specs.md`.

## Performance notes

- The retro laptop is the minimum spec, so test bullet-heavy features against it.
- Avoid giving every bullet its own `Area2D` if profiling shows a cost. Moving bullets in the manager and doing simple circle-versus-hitbox checks against the player is acceptable.
- Don't create objects every frame inside hot loops.
