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

- **Art:** Pure 2D pixel art in a 90s arcade style, with angled drawing so landmarks read well from above. The aliens have violet armour and glowing green cores, and human craft are greys with red, blue and gold accents. Full style rules are in `docs/art-specs.md`.
- **Screen layout:** A playfield of about 360×360 in the centre, with HUD panels either side. The left panel shows shield, hull, focus, ordnance, score and lives. The right panel shows the special meter and charges, and the armed squad-mate.
- **Sprite sizes:** Player ships about 24×24, small enemies 16–24, mid-bosses about 64, bosses 128–200, bullets 4–8.
- **Palette:** Fixed: Resurrect 64 (64 colours, `art/palette/resurrect-64.hex`), with no exceptions, portraits included. The bright bullet colours (pink `f04f78`, cyan `30e1b9`, pale yellow `fbff86`) are reserved and never used in backgrounds.
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

- **Health:** Shields absorb hits and recharge after a few seconds without being hit. Once they're gone, hits damage the hull, which never recharges except through mid-mission repair pickups. Every hull hit gives about 1 second of invincibility; shield hits don't. Colliding with an enemy ship deals a hit the same way a bullet does (shield first, then hull), on a short cooldown so standing on an enemy doesn't rack up damage every frame. The enemy takes no damage from the collision.
- **Lives:** 3 per mission. When the hull breaks, you respawn in place with full shield and hull, brief invincibility, and a small area around you cleared of bullets. You also drop one weapon level.
- **Game over:** Losing all 3 lives offers a choice: restart the mission, or return to the hangar.

## Ships and squad

- **Choosing a ship:** You pick one of four at the start and keep it for the whole game.
- **Squad specials:** The other three ships become your specials. Each one flies in, performs its move and flies out.
- **Special meter:** It holds up to 3 charges and fills mainly from damage dealt, with a small bonus for kills. Taking hits doesn't fill it.
- **What a special does:** Its shape clears bullets and damages enemies for the special's whole duration, not just the instant it's cast — anything that stays inside it, or enters it later, keeps taking the effect, and the shape tracks the player's position for as long as it's active. The player is invincible while it plays out.

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

### Mission 2 (south): Paris

- **Route:** Flying along the Seine through the city.
- **Twist:** The Flanker's debut. Enemies enter from the sides and from behind, so the player has to watch their back. The Spinner also appears.
- **Boss:** A huge alien machine siphoning water out of the Seine (they harvest Earth's water). The Eiffel Tower appears as a set piece along the route rather than as the boss.

### Mission 2 (north): Norwegian Fjords

- **Route:** Flying up a fjord between cliffs.
- **Twist:** The fjord walls narrow and widen, squeezing the space the player can fly in. The Grand Canyon (column 6) has a similar twist, so the two need different wall shapes and timing to stay distinct.
- **New enemy:** The Carrier (slow, armoured, launches smaller enemies).
- **Boss:** An alien drill rig boring into a glacier to harvest ice and meltwater, with drill arms and turrets.

### Mission 3 (north): Siberian Ice

- **Route:** Flying over frozen tundra and ice fields where the aliens are harvesting ice.
- **Twist:** Ice fog. Dithered fog banks roll down the screen and partly hide enemies and bullets inside them, so the player reads the edges and avoids the thickest patches.
- **New enemy:** The Burrower, surfacing from the ice. The Carrier and the Flanker join the pool.
- **Boss:** A harvester convoy: a train of armoured ice tankers crossing the tundra, led by an engine. The player destroys the cars one by one, then the engine. (The original "alien drilling rig" idea moved to the Fjords boss.)

### Mission 3 (south): Cairo and the pyramids

- **Route:** Flying over the desert past Cairo towards Giza.
- **Twist:** Sandstorms. Telegraphed gusts sweep across the screen and push the player sideways for a few seconds, so the player has to steer against them.
- **New enemy:** The Burrower, surfacing from the sand. The Carrier and the Flanker join the pool.
- **Boss:** A pyramid fortress. An alien ship has fused onto the Great Pyramid. Its faces slide open to fire, then the capstone opens into a turret core.

Column 3 is a step harder than column 2.

### Mission 4 (north): Great Wall of China

- **Route:** Following the Great Wall as it snakes over the hills.
- **Twist:** The camera follows the Wall. The ground pans side to side as the Wall winds, so the terrain drifts diagonally under the player at times. Crawlers ride along the Wall itself.
- **New enemies:** The Sniper and the Crawler (locked to the Wall). Regular enemies switch to their Mk II variants from this column.
- **Boss:** A mechanical serpent-dragon coiling along the Wall. Its body segments can be destroyed; the head is the core.

### Mission 4 (south): Himalayas / Everest

- **Route:** Climbing the Himalayan slopes towards the summit of Everest.
- **Twist:** Avalanche lanes. Telegraphed avalanches thunder down a lane of the screen. The player must get out of the lane or take heavy damage, but the avalanche also wipes out enemies and bullets in its path.
- **New enemies:** The Sniper and the Mine layer. Regular enemies switch to their Mk II variants from this column.
- **Boss:** An alien summit relay array built on Everest's peak. Rotating dish arrays fire sweeping beams of bullets, a hint towards the midgame reveal.

Column 4 is a step harder than column 3, and the second mid-boss (a Carrier-class escort mothership) arrives here. Column 4 is also where the midgame reveal plays, on either route.

### Mission 5 (north): Tokyo

- **Route:** Flying low over Tokyo at night.
- **Twist:** Neon billboard bands. Giant holographic billboards scroll through the playfield as flickering, dithered neon bands that partly mask the bullets inside them. Cloakers lurk in them.
- **New enemies:** The Cloaker and the Shielder.
- **Boss:** A kaiju-style alien walker stomping through the city. Its arms and back cannons are separate targets; the body is the core.

### Mission 5 (south): Sydney

- **Route:** Flying across Sydney Harbour, past the Opera House and under the Harbour Bridge.
- **Twist:** Tether beam fences. The Tether pair's debut is the twist: beams stretch across the harbour and sweep the screen, so the player picks the gap or kills one end to drop the beam.
- **New enemies:** The Tether pair and the Shielder.
- **Boss:** A harbour leviathan, a huge alien submarine that surfaces, dives to dodge (it can't be hit while under), and resurfaces somewhere else firing from opened hatches.

Column 5 is a step harder than column 4. Regular enemies stay Mk II and the escort mothership is the mid-boss.

### Mission 6 (north): Grand Canyon

- **Route:** Flying down the Grand Canyon.
- **Twist:** The canyon walls narrow the playfield, but unlike the Fjords' smooth bends the channel snakes in sharp zigzags, and free-standing rock pillars stand in the middle of the channel to weave around.
- **New enemies:** The Kamikaze and the Splitter.
- **Boss:** A huge alien mining crawler wedged across the canyon, with grinding drum cutters and turrets, chewing through the rock as it advances up the canyon at the player.

### Mission 6 (south): Rio de Janeiro

- **Route:** Sweeping along Copacabana and the coast past the favela hills.
- **Twist:** Sea strikes. Alien ships rise out of the sea in waves from the side of the screen, signalled by splashes. Christ the Redeemer appears as a set piece on Corcovado.
- **New enemies:** The Kamikaze and the Splitter.
- **Boss:** A fortress on Sugarloaf Mountain. Armoured cable cars run along the wires between the peaks as moving turrets, guarding a core in the mountain.

Column 6 is a step harder than column 5. Every enemy type is in the pool from here, regular enemies stay Mk II and the escort mothership is the mid-boss.

### Mission 7: Orbital

A dogfight through wrecked satellites and alien fleets as Earth recedes below. Enemies are the Space variants (steel-blue armour, wider spreads). The mothership is the boss, fought in two parts: the six turrets on its outer hull (the hull itself can't be hurt), then the core, which emerges from the hull's hatch once the turrets are gone. When the core dies the portal opens and the squad dives into it.

### Mission 8: The homeworld

1. **The arrival:** You exit the portal into their air defences, over a scorched world mined down to ash and lava seams. Elite enemies (crimson armour, white glow, an extra bullet layer) and ground flak turrets.
2. **The foundry:** The ground switches to the portal foundry behind a huge blast gate. Molten metal pours down lanes (telegraphed like the Himalayan avalanches).
3. **The Gate Core:** The final boss, fought in three phases. Shield emitters orbit the core and must be destroyed first; then the exposed core spins up; below a quarter health it melts down, with dense counter-spirals and Elite kamikazes warping in.
4. **The escape:** An enemy-free sprint back through the collapsing portal: a 40-second countdown, falling debris that costs 3 seconds per hit (no damage), and the time left paid out as a score bonus. The squad flies out through the exit portal.

After that, the squad emerges above Earth (Steel's ending lines), the credits roll over Earth, and the sequel hook types out: the Alliance has noticed humanity.

## Enemies and bosses

- **Regular enemies:** 15 types, used everywhere. The full roster, with each type's role, telegraph and debut mission, is in `docs/enemy-roster.md`. Harder variants are recolours with more bullets or new patterns (Mk II for columns 4–6, Space for Orbital, Elite for the homeworld).
  - Original 9: Drone, Swarmer, Lander pod (crash-lands on rooftops and landmarks and unfolds into a gun emplacement), Spinner, Flanker, Carrier, Sniper (telegraphs a laser before firing), Shielder, Kamikaze.
  - Added 6: Burrower, Mine layer, Splitter, Tether pair, Crawler, Cloaker.
  - Debuts are planned per column. Anything introduced in either lane of a column joins both lanes from the next column, so every route has met every type by column 6.
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
