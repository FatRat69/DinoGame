# Dinosaur Command — Implementation plan and gates

Every phase has a human-reviewed, playable exit criterion. Code generation is not a substitute for inspecting, balancing and playtesting inside Roblox Studio.

## Phase 0 — Project/toolchain
**Implement:** Git repository, Roblox Studio place, Rojo-compatible file layout, readme, simple test harness.
**Test:** Two collaborators clone, sync and launch the same code into Studio with no unexplained errors. Verify server and client actually exchange input/state.

## Phase 1 — Real-time command combat (first requested Codex task)
**Implement:** Flat test arena; two labelled primitive dinosaur placeholders (Deinonychus ordered by human, Gallimimus AI); stance buttons (Offensive/Neutral/Defensive/Flanking); Bite, Swipe, Rest; server-authored combat HP/Stamina; Damage/Effort/Accuracy and move windup/recovery/cooldown; autonomous position AI; hit/miss feedback; victory/defeat and restart.
**Unit tests:** stamina cannot go negative; illegal attacks rejected without HP/stamina effects; accuracy clamped; armor handling; cooldown checks; battle result resolves once.
**Playtest:** ~20 full battles. Stances should feel recognizably distinct, manual Rest timing should matter, all commands should be responsive and combat should not stall because of pathing/AI.
**Gate:** 3–5 novices can win/lose and understand commands without an explanation; combat feels worth improving, not just passable.

## Phase 2 — Per-move DNA puzzles
**Implement:** 5x5 puzzle board for each of two attacks; 5–8 unique finite pieces; drag/drop/rotate/remove, stats preview and server validation. Moves have different trade-offs.
**Unit tests:** all four rotations; no overlap, out-of-bounds placements or double ownership; reload/rebuild the exact state; modifiers cannot bypass min/max rules.
**Gate:** players can articulate a reason to choose different layouts and do not simply fill the board with universally superior pieces.

## Phase 3 — Skill acquisition and run-specific decisions
**Implement:** seeded reward chances scaled by prebattle relative threat; trivial enemies give no progression; one-time opponent learning chance consumed on victory; winning species alone eligible; five attack skill slots; replacement upgrade lineages; DNA-piece drops and encounter/reward log. Starter selection between Deinonychus/Gallimimus.
**Tests:** fixed-seed reproduction, eligibility and threshold edge cases, reward assignment to actual winning species, no duplicate rewards, no reward on failure or weak opponents, correct lineage replacement, legal five-slot operations.
**Gate:** at least 25–50 repeated test runs create varied viable combat builds and meaningful missed opportunities, without routinely ending runs because of one unlucky reward roll.

## Phase 4 — Four-species team test
**Implement:** Deinonychus, Gallimimus, Triceratops and Allosaurus (all placeholders); recruit/rescue system; up to five slots (only four available yet); unique species roles and counters.
**Tests:** matchups with smaller faster dodge-capable species versus larger slower heavy hitters. Verify Rest/effort economy matters; no species is strictly dominated. Ensure permanent upgrades, if introduced, do not erase these trade-offs.
**Gate:** testers give different defensible choices about which dinosaur should face a scarce skill-bearing foe.

## Phase 5 — Fixed world + variable encounters + story slice
**Implement:** A small **hand-authored and unchanged** reserve landscape, fixed labs/paths/biome boundaries, 10–20 vetted spawn zones. For each seeded run vary enemy quantity/placement/threat and chip status. Intro device discovery, one transmitter facility, one narrative goal, minimal journal. Optional scanner goggles to reveal which *party species might learn* from a particular enemy; make non-guarantee explicit.
**Tests:** 100+ generated encounter layouts: path reachable, no overlapping wildlife, no boss in safe start zone, fixed geography identical across seeds; scanner displays eligibility consistent with reward rules.
**Gate:** repeat same map on different seeds and get different tactical and progression decisions without feeling random or unfair.

## Phase 6 — Persistence and complete core content
**Implement:** Versioned persistent profile (species discoveries, story/lore/journal, scanner knowledge, approved long-term upgrades) separated from disposable run state. Save/resume rules, run reset. Continue roster toward all twelve species and build unique attack animations/rigs in waves.
**Tests:** migrate old profile formats, handle failed datastore writes, prevent dupes/rollbacks, resume interrupted runs according to policy. Mobile and desktop performance; test Brachiosaurus scale/camera/pathing early enough to catch architectural trouble.
**Gate:** no lost discoveries in recovery tests, no cascading numerical power creep, all creatures have identity and counters.

## Phase 7 — Extended story, world polish and optional encounters
**Implement:** Full island landmarks, quests, story, premium animation quality, sound, additional controlled/wild encounters, Pteranodon and Mosasaurus as non-playable threats/set pieces. Continue encounter variation, **never randomly rebuild the terrain**.
**Tests:** 30+ complete seeded runs; encounter frequency and difficulty distributions, device performance, game stability, variety of builds, accessibility of dodge/Rest/attack UI on touchscreens.
**Gate:** replayability comes from choices and outcomes, not forced grinding or cosmetic dice rolls.

## Metrics worth tracking in consenting playtests
Stance selection and time; move selection success/miss rate; fight duration; rest timing and stamina wastage; win rate adjusted for species/matchup/skill; loot/reward rate by threat ratio; which dinosaur takes high-value encounters; DNA loadout diversity; reset/restart frequency; which information the scanner changed; spawn placement quality. Do not collect unnecessary personal data.

## Technical note
Rojo setup documentation: https://rojo.space/docs/ . Roblox Studio docs for client-server security and DataStores: https://create.roblox.com/docs/scripting/security/client-server-boundary and https://create.roblox.com/docs/cloud-services/data-stores . Links are guidance; confirm current tooling when implementation begins.
