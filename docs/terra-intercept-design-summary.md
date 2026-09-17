# Terra Intercept — Design Summary

*Working title. A hobby project: a finished game with our names in the credits.*

## Team, tools and platform

- **Team:** You handle design, code (with Claude Code), pixel art conversion and music. Your wife draws concept art freehand, which you convert to pixel art.
- **Engine:** Godot 4.4+ with the Compatibility renderer, written in GDScript with static typing everywhere.
- **AI tooling:** Godot MCP Pro (paid), which works on the live editor so scenes are built as real, editable `.tscn` files.
- **Version control:** Git (already installed), with GitHub as the project's home.
- **Platform:** Windows desktop. It must also run on the retro laptop (i7-1165G7, 16GB, Iris Xe).
- **Controls:** Designed for a gamepad first, with keyboard and mouse also supported.

## CLAUDE.md hard rules

1. Scenes are `.tscn` files with nodes in the tree, and scripts contain behaviour only.
2. Tuning values are `@export` variables.
3. Game data (ships, enemies, upgrades, missions) lives in `.tres` Resources that can be edited in the Inspector.
4. The viewport is 640×360, scaled by whole numbers only (3× for 1080p, 4× for 1440p, 6× for 4K), with nearest-neighbour filtering.
5. GDScript uses static typing throughout.
6. Bullets are spawned and pooled in code; this is the one exception to rule 1.
7. The game is locked to 60fps.

## Presentation

- **Art:** Pure 2D pixel art in a 90s arcade style, with angled drawing so landmarks read well from above.
- **Screen layout:** A playfield of about 360×360 in the centre, with HUD panels either side showing the pilot portrait, shield and hull, special charges, focus meter, ordnance and score.
- **Sprite sizes:** Player ships about 24×24, small enemies 16–24, mid-bosses about 64, bosses 128–200, bullets 4–8.
- **Palette:** Fixed at 32–48 colours. The bright bullet colours are reserved and never used in backgrounds.
- **Options:** CRT scanline filter, screen-shake setting, button remapping, high-contrast bullet outlines, and a numbered Sound Test (tracks unlock once heard, all sound effects available from the start, with track names and a "composed by" credit).
- **Language:** English only.
- **Credits:** Everyone who contributed is named.

## Core gameplay

- **Style:** Vertical scrolling bullet hell with a small hitbox and dense patterns. It's a little more forgiving than the genre usually is, and difficulty ramps up across the missions.
- **Controls:**

  | Input | Action |
  |---|---|
  | Left stick | Move |
  | Right stick | Fire in the stick's direction (releasing it stops firing) |
  | LT | Focus mode: slows enemy bullets so patterns are easier to read and thread; movement speed and hitbox are unchanged. It runs off a meter that lasts about 4 seconds and starts refilling about 2 seconds after release. |
  | LB / RB | Cycle between squad-mates |
  | RT | Launch the selected squad-mate's special |
  | A | Fire ordnance in the direction you're moving (straight up if the left stick is idle) |

- **Health:** Shields absorb hits and recharge after a few seconds without being hit. Once they're gone, hits damage the hull, which never recharges except through mid-mission repair pickups. Every hull hit gives about 1 second of invincibility; shield hits don't.
- **Lives:** 3 per mission. When the hull breaks, you respawn in place with full shield and hull, brief invincibility, and a small area around you cleared of bullets. You also drop one weapon level.
- **Game over:** Losing all 3 lives offers a choice: restart the mission, or return to the hangar.

## Ships and squad

- **Choosing a ship:** You pick one of four at the start and keep it for the whole game.
- **Squad specials:** The other three ships become your specials. Each one flies in, performs its move and flies out.
- **Special meter:** It holds up to 3 charges and fills mainly from damage dealt, with a small bonus for kills. Taking hits doesn't fill it.
- **What a special does:** It clears every bullet inside its shape and damages every enemy inside it. The player is invincible while it plays out.

| Ship | Pilot | Traits | Special |
|---|---|---|---|
| Interceptor | Dash | Fast, fragile | Vertical line across the full playfield, about 40px thick |
| Striker | Bucky | High power | Cone reaching about half the screen |
| Guardian | Max | Slower, big shield | Circle about 120px across |
| Vanguard | Tammy | All-rounder | Horizontal line across the full playfield, about 40px thick |

- **Weapons:** Each ship keeps its own signature weapon, powered up from level 1 to 5 by mid-mission pickups.
- **Ordnance:** A single slot holding missiles, a homing swarm or mines, with about 5 shots maximum. Pickups either top up the ammo or swap the ordnance type.
- **Commander:** Steel, a gruff, older ex-pilot who gives the briefings.

## Pickups, upgrades and saving

- **Temporary pickups:** Weapon power-ups, ordnance, hull repair and instant special charge. All of these are lost at the end of each mission.
- **Alien tech:** Destroyed enemies drop it, with harder enemies dropping more. It scrolls down the screen and you have to fly over it to collect it; a magnet upgrade could come later. Tech is banked only when you complete a mission. If you fail, that mission's tech is lost.
- **Hangar upgrades:** A list of what's currently available. Examples include a better starting weapon, more hull, stronger shields, special meter rate, focus duration, ordnance capacity and tech magnet. Some upgrades unlock by map column reached, regardless of which lane you took.
- **Saving:** Progress saves only after a completed mission. There are 3 save slots.
- **Returning to the hangar after a game over:** Only the purchases made since the last completed mission are refunded.
- **Pause menu:** Resume, Options, Restart Mission, and Quit to Hangar (which follows the same refund rule).
- **Difficulty:** Easy and Normal use identical bullet patterns. Easy only changes damage taken, shield recharge speed and focus cooldown. A Hard or "Arcade" mode (more bullets, no upgrades) can come after launch.
- **Score:** Arcade flavour only, not part of the story. Enemies are worth different amounts, kill chains build a multiplier, and a mission-end bonus counts completion, lives, hull and shields. Each mission gets a letter grade, and there's a local high-score table with three-letter initials.

## Map and missions (13 in total, 8 per playthrough)

The route runs eastward in two lanes. You choose a lane after columns 1, 3 and 5, which gives 8 possible routes.

| Column | North lane | South lane |
|---|---|---|
| 1 | London (fixed tutorial) | — |
| 2 | Norwegian fjords | Paris |
| 3 | Siberian ice (alien drilling rig, ice fog) | Cairo & pyramids (sandstorms) |
| 4 | Great Wall of China | Himalayas / Everest (thin air, avalanches) |
| 5 | Tokyo (neon hides bullets) | Sydney (Opera House, harbour) |
| 6 | Grand Canyon (walls narrow the playfield) | Rio (Christ the Redeemer, coastline) |
| 7 | Launch from Cape Canaveral: orbital dogfight toward the portal | |
| 8 | The alien homeworld | |

Each location has its own gameplay twist. Difficulty is set per mission and rises further along the map. Bullet patterns are fixed so players can learn them.

### Mission 1: London (tutorial)

- **Route:** Flying up the Thames. It runs slightly longer than other missions.
- **Tutorial section:** Short prompts from the commander, shown only when the screen is quiet, teach movement, aiming, pickups and tech, focus, and ordnance. Squad-mates then radio in to introduce specials. Hits still drain shields and hull during this section, but the hull can't drop below 1. Anything lost is quietly restored when the tutorial ends.
- **Live section:** From there the run to Tower Bridge and the boss play normally. If you die after finishing the tutorial, restarting offers "Skip tutorial."

### Mission 7: Orbital

A dogfight through wrecked satellites and alien fleets as Earth recedes below. The mothership is the boss, fought in two parts: the outer hull and its turrets, then the core. The mission ends with the squad diving into the portal.

### Mission 8: The homeworld

1. **The arrival:** You exit the portal into their air defences.
2. **The foundry:** A scrolling run through the complex where portals are built.
3. **The Gate Core:** The final boss, fought in several phases.
4. **The escape:** An enemy-free sprint back through the collapsing portal, with a bonus for time remaining.

After that, the squad emerges above Earth, the ending plays and the credits roll.

## Enemies and bosses

- **Regular enemies:** 9 types, used everywhere. Harder variants use recoloured sprites with more bullets or new patterns.
  1. Drone
  2. Swarmer
  3. Lander pod, which crash-lands on rooftops and landmarks and unfolds into a gun emplacement
  4. Spinner
  5. Flanker
  6. Carrier
  7. Sniper, which telegraphs a laser before firing
  8. Shielder
  9. Kamikaze
- **Mid-bosses:** 2–3, reused and recoloured across missions.
- **Bosses:** A unique boss for each Earth mission, plus the mothership and the Gate Core.
- **Mission length:** 4–6 minutes.

## Story

- **Delivery:** Portrait-and-text-box scenes before and after missions. Occasional short messages during a mission appear only when the screen is quiet. Two short animated cutscenes: the opening invasion and the portal approach.
- **The aliens:** Their whole society runs on a trace mineral or isotope. It's rare in space, and they have exhausted their own world's supply. They invade worlds that have it, wipe out the population and set up mining colonies, sending the mined resources home through a portal (hyperspace gate). Earth has one of these portals just outside orbit.
- **Earth's role:** Our water contains the mineral, and we never knew it was there. The aliens drain water and ice, which is why the Siberian rig and the coastal attacks happen.
- **Tone:** The massacres of other worlds are only mentioned, in briefings and a line or two of dialogue, never shown. Recovered alien tech reveals other worlds under attack. Earth's cities are under attack but never shown as massacres, which keeps the bright 90s-heroics feel.
- **Midgame reveal (column 4, reached on every route):** The technician finds that a frequency the humans can now produce, using alien tech, destabilises the refined mineral. Delivered into the Gate Core, it would set off a chain reaction that collapses every portal the aliens have, stranding their colonies and ending their expansion.
- **Upgrade flavour:** Upgrades are presented as humans studying and adopting the alien tech.
- **Homeworld look:** Scorched and industrial, stripped bare by its own mining. It tells their story without text.
- **Sequel hook:** Another alien race notes that humanity destroyed the miners and is now ready to meet "the Alliance."

## Audio

- **Music:** Written by you in a modern chip-arcade style. Tracks are OGG files with an intro plus a loop section, and boss phases switch to a new section.
- **Sound effects:** Made with jsfxr or ChipTone.
- **Track list (15):**
  1. Title
  2. Hangar/map
  3. Tutorial
  4. Stage theme 1
  5. Stage theme 2
  6. Stage theme 3
  7. Stage theme 4
  8. Stage theme 5
  9. Mid-boss
  10. Boss
  11. Orbital (mission 7)
  12. Mothership
  13. Homeworld (a darker, alien variation on the title theme)
  14. Gate Core final boss
  15. Ending/credits

## Co-op (built for from day one, released single-player)

- **Code:** Input and player handling support player 1 and player 2 from the start.
- **In co-op:** Two ships under full player control and two specials. Each player is assigned one squad-mate and fires that special. The players decide between them which ships and squad-mates they take.

## Build order

1. **Vertical slice with placeholder squares:**
   - One ship with twin-stick controls, focus, shields and hull
   - 3 enemy types, one special and one boss
   - The 640×360 scaled window

   Test this on the retro laptop before moving on.
2. **London**, with real art, the hangar and the map.
3. **One complete route** (6 Earth missions plus missions 7 and 8), giving a finished, playable game.
4. **The remaining lane missions.**

## Deliberately left open

- Pilot and commander names.
- The final title (check Steam and itch.io for clashes before committing).
- How the specials behave in co-op beyond the basic rule above.
