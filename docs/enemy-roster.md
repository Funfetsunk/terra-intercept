# Terra Intercept — Enemy Roster

Status: **approved** (2026-09-30), 15 types. This is the reference for enemy types, their roles and which mission each debuts in. Sizes also go into `docs/art-specs.md` as each enemy is built.

## Why this exists

The design has 9 enemy types across 13 missions (8 per playthrough). Most missions should introduce something new, and London already uses 3 types, so 9 would run out by about mission 4. This draft keeps the original 9, adds 6 new types, and plans harder variants, so every column of the map brings something new.

## Principles

- **One job per enemy.** Each type has a clear role, so waves can be built from a vocabulary:
  - **Fodder:** dies fast and fills the screen.
  - **Pressure:** keeps the player moving.
  - **Zoning:** denies an area.
  - **Priority:** kill it first or it gets worse.
  - **Tank:** soaks damage and anchors a wave.
- **Readable at a glance.** Every type has a distinct silhouette at its size, and all of them share the alien look: violet armour with green glowing cores. Anything special must be telegraphed (a flash, a line or a splash) before it can hurt the player.
- **Route-proof debuts.** A player only sees one mission per column, so a debut can't assume the player has met an enemy from the other lane. Rule: the new types from both lanes of a column join the shared pool from the next column on. Later missions therefore never assume a type the player may have skipped, and a type met late gets a gentle first wave.
- **Deterministic.** Every pattern uses seeded RNG, the same as today.
- **Variants over new art.** Harder versions are palette swaps within the alien ramps, plus more bullets or new patterns. Later columns lean on variants.

## The roster

Sizes are in game pixels. **Status:** Built = in the game now; Designed = in the original design; New = proposed here.

| # | Enemy | Size | Role | Behaviour | Attack | Telegraph | Status |
|---|---|---|---|---|---|---|---|
| 1 | Drone | 16×16 | Fodder | Drifts down and sideways | Single shots, or a 3-way spread (late) | — | Built |
| 2 | Swarmer | 16×16 | Pressure | Arrives in groups and strafes in a wave | 3- or 5-way spread | — | Built |
| 3 | Lander pod | 16×24 → 24×24 | Zoning | Falls, lands on terrain, unfolds into a turret | Rapid aimed stream | 3-frame unfold before it fires | Built |
| 4 | Spinner | 24×24 | Zoning | Hovers in place | Rotating bullet ring | — | Built (art), unused so far |
| 5 | Flanker | 20×20 | Pressure | Enters from the sides or from behind, and crosses on a curve | Aimed shots while crossing | An arrow blip at the screen edge 0.5s before it enters | Designed |
| 6 | Carrier | 32×32 | Tank | Slow, armoured, crosses the screen | Launches swarmers from its bay; light aimed fire | Bay doors open before each launch | Designed |
| 7 | Sniper | 20×20 | Priority | Holds position near the top | A single fast laser shot | A 1–2px laser line that thickens over 0.8s, then fires | Designed |
| 8 | Shielder | 24×24 + 40×40 ring | Priority | Escorts other enemies | Weak shots; its ring blocks player bullets for allies inside it | The ring flickers when it's about to drop | Designed |
| 9 | Kamikaze | 16×16 | Pressure | Hovers, locks on, then dives | Explodes into a small ring on death or impact | 2–3 frame arming flash, then a lock-on line | Designed |
| 10 | Burrower | 20×20 | Zoning | Hides under terrain (ice, sand, snow), then surfaces mid-screen | Burst ring on surfacing, then aimed shots | A dust or snow puff and a shadow 0.8s before it surfaces | New |
| 11 | Mine layer | 24×24 | Zoning | Crosses slowly, dropping mines behind it | Mines (8×8) arm, then pop into a small ring after a delay or when the player is near | Mines blink faster before they pop | New |
| 12 | Splitter | 20×20 | Fodder / pressure | Drifts like a drone | On death, splits into 2–3 mini drones (10×10) that scatter | A crack flash when hit | New |
| 13 | Tether pair | 2 × 16×16 | Zoning | Two drones joined by a beam that sweeps across the screen | The beam hurts on contact; each drone fires single shots | The beam flickers on for 0.5s before it goes solid | New |
| 14 | Crawler | 24×24 | Zoning / tank | A ground tank locked to the scrolling terrain, turret tracking the player | Aimed bursts from the turret | Turret glow before each burst | New |
| 15 | Cloaker | 20×20 | Priority | Nearly invisible (a dithered shimmer) until it fires | Aimed spreads | Decloaks 0.5s before firing (fits Tokyo's neon) | New |

Built enemies keep their current behaviour and tuning. The table only fixes their role for wave design.

## Debut schedule

Each column lists what debuts in each lane. Anything that debuted in either lane of an earlier column is in the shared pool.

| Column | North lane | South lane | Notes |
|---|---|---|---|
| 1 | London: Drone, Swarmer, Lander pod | — | Built |
| 2 | Norwegian Fjords: **Carrier** (+ Spinner) | Paris: **Flanker** (+ Spinner) | Decided. The Spinner appears in both lanes. |
| 3 | Siberian Ice: **Burrower** (surfacing from ice) | Cairo: **Burrower** (surfacing from sand) | Same debut in both lanes, themed per location. Carrier and Flanker join the pool. |
| 4 | Great Wall: **Sniper**, **Crawler** (on the wall) | Himalayas: **Sniper**, **Mine layer** (avalanche slopes) | Sniper in both lanes. This is the midgame-reveal column. |
| 5 | Tokyo: **Cloaker** (neon hides it), **Shielder** | Sydney: **Tether pair** (across the harbour), **Shielder** | Shielder in both lanes. |
| 6 | Grand Canyon: **Kamikaze**, **Splitter** | Rio: **Kamikaze**, **Splitter** | Same in both lanes, so everything is in the pool by column 7. |
| 7 | Orbital: space variants of the whole roster, plus the mothership's own turrets | — | Variants debut here. |
| 8 | Homeworld: elite variants, foundry turrets, the Gate Core | — | Hardest variants. |

Every route meets every type by column 6. Lane-exclusive debuts (Crawler, Mine layer, Cloaker, Tether pair) are the flavour of a lane, not the only place a player can meet them: from column 6 they can appear anywhere as part of the pool.

## Variants

| Tier | Where | Look | Change |
|---|---|---|---|
| Base | Columns 1–3 | Violet armour, green glow | As built |
| Mk II | Columns 4–6 | Deeper violet, amber glow (`9e4539` … `f9c22b`) | More bullets per burst, slightly faster shots |
| Space | Column 7 | Steel-blue armour (`323353` … `4d9be6`), green glow | Adapted movement for the orbital setting; wider spreads |
| Elite | Column 8 | Crimson armour (`753c54` `831c5d` `a24b6f` `c32454`; never the reserved bullet pink `f04f78`), white glow | Extra pattern layer; the tougher, final form |

Variants are palette swaps made with the existing remap tooling. No new drawing.

## Mid-bosses and bosses (for context)

- **Mid-bosses (2–3, reused and recoloured):**
  - The built Sentinel gunship covers columns 1–3.
  - A second mid-boss is needed by column 4, perhaps a Carrier-class mothership escort.
  - A third for columns 6–8 is optional.
- **Bosses:**
  - Built: Tower Bridge (London).
  - Decided: Seine siphon (Paris), glacier drill rig (Fjords).
  - The remaining nine are still to be designed with the developer.

## Build cost estimate

- Each new type needs art: 2–4 frames, generated and palette-remapped as with London's enemies.
- A movement/attack script extending `EnemyBase`.
- An `EnemyData` resource and at least one pattern resource.
- The Carrier, Shielder, Tether pair and Crawler also need small engine additions:
  - Carrier: spawning children.
  - Shielder: a bullet-blocking area.
  - Tether pair: a beam-contact check in the bullet manager.
  - Crawler: locking to the background scroll.
- Burrower and Cloaker only need timed visibility.
