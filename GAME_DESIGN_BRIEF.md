# Dinosaur Command — Game Design Brief v0.2

**Status:** preliminary design decisions. All mathematical balance values and move lists below are *original proposed prototype numbers*, not verified statistics from any earlier game.

## Non-negotiable game pillars
1. **Agent fantasy.** A human field agent finds a technological controller to communicate with and command prehistoric animals. A conspiracy involving artificial control implants provides a narrative throughline. The player directs an animal, rather than controlling its body directly.
2. **Continuous real-time one-on-one combat.** The combat simulation does not alternate turns. The player chooses one of **Offensive / Neutral / Defensive / Flanking** stances and directs available attacks, while the dinosaur automatically moves and fights. The user chooses when to Rest between moves. All combat, targeting and resource calculations are server-authoritative.
3. **Finite team each run.** Each run starts with a choice of **Deinonychus** or **Gallimimus**. A run can contain no more than **five** owned dinosaurs, while the full game has **twelve playable dinosaur species**. Do not make all twelve automatically recruitable in every run.
4. **Irreversible learning opportunities.** A completed encounter credits the dinosaur that wins it. Other roster dinosaurs miss their opportunity to earn a combat skill from that unique opponent. There is no catch-up system that always unlocks every move.
5. **Randomized skill progression.** Skill acquisition is determined by a seeded random roll, filtered by species-compatible move pools and scaled by how threatening the opponent is relative to the winning dinosaur at battle start. Trivial opponents never award skills/DNA progression. Skill offers are not guaranteed on qualifying victories.
6. **Move slots/lineages.** Each dinosaur may have at most **five equipped combat skills**. The potential skill pool per species is larger than five. Some are explicit upgrades that replace the prior tier of the same move lineage. Universal controls (Rest / stance / Dodge if implemented) do not occupy one of five attack slots. If a non-lineage move is obtained with slots full, require an explicit replacement choice.
7. **Skill-specific DNA puzzles.** Every offensive move has its own grid, optimized with finite DNA polyomino pieces obtained during the run. Pieces affect that move's **Damage, Effort, Accuracy**, and sometimes secondary effects. Pieces cannot be duplicated across moves.
8. **Permanent island, variable encounters.** The geographic world, biomes, major paths, landmarks, research stations and story locations remain **the same on every run**. Vary the **number, location, composition, rarity, and enhanced/wild status** of opponents via seeded encounter placement in authored spawn zones. Do NOT generate a different island or randomize world geometry between runs.
9. **Persistent discovery, run-specific strength.** Preserve discovered species (field guide and eligibility for future recruitment), story information, journal entries and carefully chosen other metaprogression between runs. Reset each run's *owned five-dinosaur team*, acquired combat skills, move DNA layouts/pieces and encounter allocation. Permanent power upgrades may exist, but must have limits and must not trivialize early encounters or make new players uncompetitive. Treat permanent passive boosts as a later design decision requiring balancing.
10. **Optional analysis goggles.** A findable/equippable **scanner goggles** or analysis visor item can indicate whether the current enemy has a chance to teach a particular dinosaur in the player's party a skill. They should reveal eligible roster species and approximate potential, **not promise a guaranteed unlock**. Before finding goggles, players can learn from observation, scouting and experimentation. This is a discovery tool, not a paywall.

## Dinosaur roster (12 playable)
| Species | Role / tactical feel | Classification note |
|---|---|---|
| Deinonychus | Fast flank attacks; high dodge/attack speed and efficient stamina cycling | Feathered predatory dromaeosaurid; starter |
| Gallimimus | Extremely mobile, evasive, low-damage attrition and quick recovery | Ornithomimid omnivore; starter |
| Dilophosaurus | Fast reach attacks, spacing and interruption | No natural venom-spitting/frill assumptions |
| Stegosaurus | Tail-spike deterrence, area denial, committed counterattacks | Herbivore |
| Triceratops | Head-on armor, horns, charges; vulnerable to rear/side angles | Herbivore |
| Ankylosaurus | Heavy defense, powerful tail-club response, slow maneuvering | Herbivore |
| Tyrannosaurus | Very strong bite, high burst and stagger; long effort/recovery commitment | Large predator |
| Spinosaurus | Extended reach and environmental versatility, but not magical swimming advantages | Predatory theropod |
| Allosaurus | Flexible midsize-to-large combo specialist | Predatory theropod |
| Parasaurolophus | Mobile hadrosaur with defensive spacing and kicking attacks | Hadrosaurid herbivore |
| Brachiosaurus | Extreme mass/reach, stomps and endurance; slow windups/turning | Sauropod herbivore; model last |
| Giganotosaurus | Long-reach sustained attack pressure versus T. rex burst identity | Carcharodontosaurid predator |

The twelve above are **six broadly predatory theropods plus six non-predatory/omnivorous species** (the ornithomimid is an omnivore; precise trophic classifications should remain scientifically honest). Keep model and movement physiology informed by paleontology while granting fictional tactics explicitly where necessary.

**Nonplayable prehistoric reptiles:** Pteranodon (a pterosaur) and Mosasaurus (a mosasaurid squamate) are biome threats or special encounters. Neither is a dinosaur. Do not build flight/swimming player controls in MVP.

**Hadrosaur decision:** Parasaurolophus is selected for the distinct silhouette and familiar crest. **Iguanodon** is a good possible swap when emphasis is on combat (thumb spike), but it is not a hadrosaurid. Shantungosaurus creates more overlap with Brachiosaurus's enormous-size identity.

## Character stats, size trade-offs and commands
- Base dinosaur properties: **Health, maximum Stamina, Armor, movement speed, turn rate, Dodge, stamina regeneration/rest recovery, and attack-animation timing**. These depend on species, then may be altered by authored equipment/upgrade mechanics later.
- Every move exposes the original-inspired visible triad: **Damage**, **Effort** (stamina consumption), **Accuracy** (hit chance). Also define Range, Windup, Active Window, Recovery, Cooldown, Allowed Stances, tags and effects.
- **Small dinosaurs must remain competitively valuable.** In the initial balancing philosophy they generally have **better stamina efficiency**, **faster attacks / shorter windup and recovery**, **higher dodge potential**, and better maneuverability. Larger dinosaurs generally gain **health, armor, reach and per-hit force**, with slower attacks and more stamina-consuming commitments. These are balancing tendencies, not rigid rules; upgrades can enhance an individual animal's attributes.
- **Manual Rest is essential.** A player must plan Rest windows between attacks based on opponent posture, recovery windows and danger. Do not quietly replace it with automatic stamina recovery that removes the tradeoff. Small dinosaurs may recover faster or spend less per move, but still need to make decisions about Rest.
- Offensive: close distance and look for an attack lane. Neutral: balanced distance/defense. Defensive: open distance or hold defensible angles; enable rest/dodge. Flanking: work toward rear/side with higher movement commitment. Keep all responsive as time advances.
- For MVP combat, 1 player-ordered dinosaur versus 1 opponent. Select team dinosaur before encounters; do not add mid-fight roster switches in the prototype.
- Server tracks state: idle, navigating, windup, strike, recovery, resting, dodging, stunned, defeated. Enemy chooses attacks autonomously. Explicit visuals must communicate windup, strike, miss, and recovery.
- Balance must not be mass = strictly better. A well-trained Gallimimus or Deinonychus should counter some larger species situationally without unrealistically claiming equal physical strength or bite force.

## Example progression tuning (original design; not canonical historical data)
Let `threatRatio = effectiveEnemyThreat / effectivePlayerThreatAtBattleStart`.
- `<0.85`: 0% progression (trivial).
- `0.85–1.04`: 20% progression reward.
- `1.05–1.39`: 45% progression reward.
- `1.40–1.79`: 65% progression reward.
- `>=1.80`: 80% progression reward.
These thresholds are only initial hypotheses. Threat can combine effective HP, armor, animation speed, dodge, stamina economy, move loadout and encounter buffs. Freeze threat estimate when battle starts, so players cannot intentionally deplete their HP to manipulate reward odds. Seed every roll and log it for testing.

If an encounter gives a progression reward, choose from eligible **skill offer / upgrade offer / DNA piece**, with configurable drop weights. Never fake a roll when no skill is eligible. A one-time encounter is consumed after victory whether or not its learning roll succeeds; this makes irreversible choice real, but may need clarity and playtest tuning.

## Analysis goggles (not necessarily in the first prototype)
- Item can be discovered in a designated hand-built story location or through a carefully authored optional exploration objective. Keep placement stable unless designers deliberately vary it.
- On inspecting a live enemy, server evaluates **each dinosaur currently in the team** for *potential* to learn something if it wins. Output might be `Possible skill potential`, `Already knows likely compatible lineages`, `Enemy too weak`, or `Unknown signal` rather than exposing the exact random result.
- An **enhanced/chipped** enemy may unlock additional insight (e.g. implant severity). This should fit the story but not conflate scanner eligibility with guaranteed acquisition.
- Players retain discovery of the scanner in their journal across runs; whether the physical visor must be found again is a separate choice (initial recommendation: keep its information unlock persistently after discovery, with a potentially upgradable visor later).

## Skill-specific DNA board
- Initial placeholder board: **5x5** on each offensive move, subject to subsequent tuning. Each piece consists of integer-offset grid cells and unique run-owned piece instance ID; supports quarter-turn rotation and moving/removing.
- Give pieces trade-offs: e.g. +8 Damage, +3 Effort, -4 Accuracy; or +7 Accuracy, -2 Damage, -1 Effort. Define caps/floors in one module, especially for accuracy and effort.
- Client previews stat changes; server validates ownership, board bounds, unique piece use, overlap, rotation, modifiers and commit. No two skills can use the same piece instance simultaneously.
- Upgraded move lineage should inherit the previous board investment without deleting pieces; a new board shape/special cells could be a future explicit upgrade mechanic. Five slots remains a hard cap.

## Fixed-map seeded encounter variation
- Build **authored terrain and landmarks** once: forests, wetland, grassland, highland, labs and storyline locations as needed. Major paths and obstacles never procedurally change per run.
- Each spawn location has constraints: `biome`, `eligibleSpecies`, `maxThreat`, `minThreat`, `enhancedAllowed`, `exclusionRadius`, `storyPhase`, and `respawnPolicy`.
- Use the run seed to select encounter count, composition and placement per zone. Avoid overlaps, unreachable locations, critical story blocks, unfair starter-zone apex spawns, and too-few reward-eligible fights.
- Unique key opponents/bosses can be fixed to story locations while optional/random encounters move among authored sites.
- For early prototype this is **not implemented yet**, but the run model should eventually make reproducing an encounter placement from its seed straightforward.

## Persistence
- **Persistent across runs:** species sightings/discoveries, permanent recruitment eligibility/unlocks as authored, story chapter flags, logbook entries, scanned enemy knowledge, optional cosmetics and a small number of carefully balanced achievements/upgrades.
- **Reset each run:** owned team (max 5), earned moves and move upgrades, all DNA pieces and fitted layouts, current run encounter roster/spawn locations, HP/Stamina, victory/loss state, per-run scanner loadout where appropriate.
- Persistence implementation is later scope; start with schema and tests before DataStore use. Include explicit migration/version handling and robust save-failure handling.

## Original game verification caution
Reference inspiration: the 2002 Jurassic Park: Dinosaur Battles displayed move **Damage / Effort / Accuracy**, Health/Stamina, stances and attack commands. No authenticated full canonical stats table or exact reward RNG has been established in this design package. **Do not claim prototype figures match the original**. Our game must be an original work, not an unlicensed remake.

## Out of scope for first executable prototype
No professional animal models, no full open world, no scanner, no DNA editor, no unlock RNG, no persistence, no twelve-species balance, no procedural map creation, no large-scale multiplayer, no story cutscenes and no flying/swimming mounts. First prove stance-driven real-time combat using two placeholder dinosaurs in a single arena.
