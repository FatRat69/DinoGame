# DinoGame — Phased development and playtest plan v3

Every stage must pass human Roblox Studio review before the next begins. Numbers below are testing targets, not predictions of success.

## Phase 0 — Setup and handoff
Initialize Rojo-compatible typed Luau project, Roblox Studio workflow, source layout and clear README. **Gate:** both collaborators can sync/open/play an empty project without errors.

## Phase 1 — Real-time command combat (first Codex task)
One flat arena: player-directed Deinonychus vs AI Gallimimus, basic placeholder rigs. Four stances; Bite, Swipe, timed Rest; HP/Stamina, Damage/Effort/Accuracy, hit/miss, attack windup/recovery/cooldown, AI and restart. **Gate:** about 20 completed battles and 3–5 novice testers; stances visibly distinct, Rest meaningful, no AI deadlocks or double attacks.

## Phase 2 — DNA per skill
Prototype individual move boards (5x5 provisional), limited shared polyomino inventory, rotate/place/remove, stat preview, server checks. **Gate:** boundary and rotation tests; cannot duplicate pieces or create invalid layouts; builds offer real statistical tradeoffs.

## Phase 3 — Hidden irreversible learning rewards
Implement seeded one-time encounters and reward outcomes using **intrinsic opponent formidability**, **relative threat to the winning dinosaur**, and **species/skill compatibility** separately. Trivial fights give nothing; most meaningful opponents potentially teach most species; no prebattle species/reward reveals. Five skill slots, tier upgrades replacing predecessors. **Gate:** deterministic test seeds, no rerolls/duplicates, 25–50 trial runs show varied and mostly completable builds. Finalize probabilities with designers first.

## Phase 4 — Size asymmetry, armor and counterplay
Add representative giant and Ankylosaurus placeholders; calibrate giant-vs-small imbalance, smaller animal speed/dodge/stamina efficiency and run-only upgrades. Rare plainly named Piercing/Crushing move types bypass protected Ankylosaurus armor. **Gate:** huge species consistently dominate small in straight fights, extraordinary upsets remain possible; standard hits do not damage armored regions, special hits work and no required encounter lacks a counter. Design exact armor hit zones before coding.

## Phase 5 — Fixed island and encounter generation
Author persistent geographic biomes, narrow/sinking routes for small dinosaurs, strength barriers/crossings for large, 5-dinosaur team safeguards; place seeded variable enemy numbers/locations at audited nodes; fixed scripted encounters always fire. **Gate:** 100 distinct seeds leave geography unchanged and maintain reachable goals and valid spawn locations; no party composition softlocks.

## Phase 6 — Narrative and permanent knowledge
Field agent, communication controller, wild vs implanted opponents, story missions and a **journal of observed species, discovered skills and story notes**. All dinosaur ownership, strength, skills, DNA, gear reset on new runs. **Gate:** save/reload tests, migrations, failures and no journal-based power or undiscovered skill spoilers.

## Phase 7 — Twelve-species content, visual polish and extended replayability
Paleontology-informed models and animations, more moves, biome details, audio, bosses; Pteranodon and Mosasaurus only as nonplayable threats. **Gate:** full replay runs, mobile/desktop performance, unique species roles, stable encounter generation and accessible UI.

## Decisions deliberately deferred
Final RNG formula/drop distributions; armoring weakspots and special damage types; Parasaurolophus powers; mandatory exploration recruitment safety; DNA-layout transfer on upgrade; journal spoiler boundaries. No one should invent these as finalized values in Phase 1.
