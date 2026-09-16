# CLAUDE.md — Terra Intercept

Terra Intercept is a 2D pixel-art vertical-scrolling bullet hell with twin-stick controls, built in Godot. It's a hobby project with a 90s arcade feel.

**The full design lives in `docs/design-summary.md`. Read it before building any gameplay feature.** Don't invent design decisions. If something isn't covered there or is unclear, ask before implementing.

## Current milestone

Milestone 1 (vertical slice) is complete (tag `vertical-slice`).
Milestone 2a (core systems) is complete (tag `milestone-2a`).

**Now: Milestone 2b, London (mission 1).**
Build it entirely from the 2a systems: timeline `.tres`, backgrounds, pickups, dialogue. If something can't be done with those systems, stop and ask rather than hard-coding around them. Use placeholder art wherever real art isn't ready yet, but keep sprite sizes true to the design so real art drops straight in.

Build in this order, one task at a time, committed separately:

0. **Retire the vertical slice.** Convert the slice level into a developer-only test range (`scenes/levels/test_range.tscn`) using the 2a systems. Remove it from all game menu flow. Delete slice-only code that the 2a systems replaced. Check whether the slice boss can be reused as the task-5 mid-boss. List anything you plan to delete and wait for approval before deleting it.
1. **Mission structure.** A London mission `.tres` split into three sections: tutorial, Thames run, boss. Section boundaries are markers in the timeline, so restarts can begin from a marker.
2. **Tutorial section (non-lethal).**
   - Hits still drain shields and hull, but the hull can't drop below 1.
   - Commander prompts appear only when no threats are on screen, in this order: movement → aiming/firing → collecting a power-up and alien tech → focus mode → ordnance.
   - Squad-mates then radio in, and the player uses each available special once.
   - Enemies are light and slow, and each teaching beat waits until the player has done the action.
   - When the section ends, shields and hull are silently restored to full.
3. **Skip tutorial.** If the player has finished the tutorial and later dies in the mission, the restart prompt offers "Skip tutorial," which restarts from the Thames marker.
4. **Thames run.** A scrolling flight up the river, gentle difficulty (this is the opening mission). Introduce the drone, swarmer and lander pod (pods land on rooftops and embankments). Include pickups and alien tech drops. About 3–4 minutes after the tutorial.
5. **Mid-boss.** One of the reusable mid-bosses, built so it can be recoloured and reused in later missions.
6. **Tower Bridge boss.** A unique boss attacking Tower Bridge, with 2 phases and learnable, fixed patterns. It ends with the results screen.
7. **Mission flow.** Title → ship select → London → results → back to title. (The hangar and map come in milestone 3.)
8. **Audio hooks.** Tutorial music during the tutorial, a stage theme for the Thames run, mid-boss and boss music with a phase change. Use placeholder audio files if the tracks aren't ready.

**Dialogue:** pilot and commander names aren't decided yet. Use placeholders (`COMMANDER`, `INTERCEPTOR PILOT`, and so on), kept in the dialogue `.tres` files so they're easy to replace.

**Coming later, do not build yet:** milestone 3 (hangar, upgrade list, save slots, world map), then the remaining missions.

Success means it runs at a steady 60fps on the retro laptop (i7-1165G7 / Iris Xe). Don't start on the hangar, map, story or real art until this milestone is signed off.

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
    sprites/         # exported PNGs
  audio/
    music/           # OGG files with loop points
    sfx/             # jsfxr / ChipTone exports
  data/              # .tres Resources: ships/, enemies/, patterns/, upgrades/, missions/, dialogue/
  scenes/
    player/  enemies/  bosses/  bullets/  pickups/  specials/
    levels/  ui/  hud/  menus/
  scripts/
    autoload/        # global singletons
    resources/       # custom Resource class definitions
    systems/         # bullet manager, spawner, scoring, etc.
  docs/
    design-summary.md
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

**Always code against actions, never against specific keys or buttons.** Player code must accept a player index; never hard-code "player 1".

## Collision layers

1. player (a small hitbox only, not the sprite)
2. player_bullets
3. enemies
4. enemy_bullets
5. pickups
6. specials (the area-of-effect shapes)

## Planned autoloads

These are added as each one becomes needed, not all at once:

- `GameState`: current run, lives, map position, selected ship
- `SaveManager`: 3 slots, saving only after a completed mission
- `AudioManager`: music sections and loops, sound effects, Sound Test unlocks
- `Settings`: CRT filter, screen shake, remapping, high-contrast bullets, difficulty

## Using Godot MCP Pro

The Godot editor is open and connected through Godot MCP Pro. Use its tools in preference to editing files by hand.

- **Editor tools versus runtime tools.** Editor tools (scene, node, script, project, resource, animation, shader and similar) work on the scene open in the editor and are always available. Runtime tools (game state, input simulation, capture and recording, testing, game screenshots) **only work after `play_scene`**, and they fail otherwise. Always finish with `stop_scene`.
- **Building a scene:** `create_scene` or `open_scene`, then `add_node` or `batch_add_nodes`, then `create_script` + `attach_script`, then `save_scene`.
- **Tuning values:** set node properties in the Inspector with `update_property` rather than in code. Use a script only when the value must change at runtime.
- **Project settings and input actions:** use `set_project_setting` and `set_input_action`. **Never edit `project.godot` directly**, because the editor overwrites it.
- **Testing gameplay:** `play_scene`, then drive input with **`simulate_action` using the `p1_` action names** (not raw keys), then check the result with `get_game_screenshot`, `capture_frames` or `monitor_properties`, then `stop_scene`. For the bullet manager, use `run_stress_test` and `get_performance_monitors` to check the 60fps target.
- **After script changes:** run `validate_script`. If a new script doesn't take effect, run `reload_project`.
- **Checking for errors:** use `get_editor_errors` and `get_output_log`.
- **Pitfalls:**
  - Property values are passed as strings, for example `"Vector2(100, 200)"` or `"Color(1, 0, 0, 1)"`.
  - Give for-loop variables explicit types: `for enemy: Enemy in enemies`.
  - `compare_screenshots` takes file paths (`user://...`), not image data.
  - With `simulate_key`, use short durations (0.3–0.5s) to avoid overshooting.
  - `execute_game_script` doesn't allow a function inside a function, and uses `.get("property")` for safe access.
- **If "Godot editor is not connected" appears:** a stale `node.exe` is probably holding the port. Tell the developer instead of retrying repeatedly.

## Workflow

- **Before starting a task,** check `docs/design-summary.md` and the current milestone above.
- **Do the work in the editor** through Godot MCP Pro wherever possible: create scenes, add nodes, set properties.
- **Before calling a task done,** run the project through MCP, read the output and error log, and fix any errors or warnings. Take a screenshot when the change is visual.
- **Keep changes small and focused.** One feature per commit, with a clear message (`Add focus meter to player`).
- **Git:**
  - Commit to the local repo.
  - The remote is GitHub.
  - Never commit `.godot/` (the import cache) or exported builds. `.gitignore` handles `.godot/`.
  - **Do** commit `*.import` files. In Godot 4 they hold each asset's import settings (such as pixel-art filtering), and the project needs them.
  - Ask before force-pushing or rewriting history.
- **Ask first** before adding plugins or addons, changing any hard rule or project setting, or making a design decision the summary doesn't cover.
- **Explain as you go.** The developer knows programming but is still learning Godot, so briefly explain Godot-specific choices (why a node type, why a signal) when you make them.
- **Use placeholders freely** during the vertical slice: `ColorRect` or simple shapes, sized to the design (player about 24×24, small enemies 16–24, bullets 4–8).

## Performance notes

- The retro laptop is the minimum spec, so test bullet-heavy features against it.
- Avoid giving every bullet its own `Area2D` if profiling shows a cost. Moving bullets in the manager and doing simple circle-versus-hitbox checks against the player is acceptable.
- Don't create objects every frame inside hot loops.
