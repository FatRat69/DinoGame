# Codex implementation instructions

First read `GAME_DESIGN_BRIEF.md` and `IMPLEMENTATION_PLAN.md`. This is an **original Roblox experience written in typed Luau**, not a direct copy of any existing game's assets, characters or branding.

## Scope discipline
- Work **one phase at a time**. On first request build **Phase 0 and Phase 1 only** and then stop.
- The world is fixed across runs; **do not implement procedural terrain or regenerate map geometry**. Later variation is encounter count and positions at authored spawn nodes.
- The player is a human issuing posture/attack commands to an autonomous dinosaur in **continuous real time**. No turn system; no direct movement keys controlling the dinosaur in combat.
- Small-bodied species should generally be tuned toward stamina efficiency, faster attack windup/recovery, dodging and mobility; big-bodied toward more HP/armor/reach/force. The player chooses **Rest**. Do not automate away its resource trade-off.
- Preserve species discoveries, story information and other chosen unlocks between runs; not current roster/skills/DNA, which reset. Persistent-state code is later scope.
- An **optional analysis goggles** item can later tell players *which owned species have a chance* to learn from a scanned enemy; never imply acquisition is guaranteed. Do not build goggles in Phase 1.

## Engineering rules
- Organize a Rojo-friendly repository into `src/shared`, `src/server` and `src/client` with a valid `default.project.json`, plus README setup instructions.
- Prefer data-driven, validated, small modules and pure testable combat and progression functions over giant scripts.
- Use unique, stable IDs for species, skills/upgrade lineages, battles, enemies, encounters, DNA instances and run state.
- Keep numerical tuning in explicit tables/configuration modules. Display Damage, Effort and Accuracy as the move's user-facing stats; mark initial numbers as provisional.
- The **server** owns combat HP/Stamina, cooldowns, hit/accuracy rolls, positioning/hit checks, skill unlocks, encounter consumption, RNG seed, DNA validity and rewards. The **client** requests a stance or a skill only, and displays server-state feedback.
- Reject malformed events, illegal skill IDs, missing stamina, incorrect stances, impossible attack range, repeated/hasty commands and duplicate rewards. Use minimal network messages and rate limits.
- Use seeded RNG for run randomness rather than global `math.random()`; preserve seeds in logs for reproduction.
- Never pretend a script was playtested in Roblox Studio when you only performed static checks.
- No paid random rewards, hidden monetization, copied branded assets or unapproved third-party packages.

## Workflow
1. Inspect repository, report what exists and outline a short implementation plan.
2. Produce only the current milestone's scripts and simple placeholder art/geometry needed to play.
3. Add tests for pure calculation/rules, plus a manual Roblox Studio checklist.
4. Run available formatter, syntax/build and test tools; report the exact results and limitations.
5. State how to open/sync/run in Studio, and **stop after the current phase**.

## Phase 1 goal
One real-time one-on-one fight in one flat arena: player's Deinonychus versus AI Gallimimus, both visually distinct placeholder models; selectable Offensive/Neutral/Defensive/Flanking; Bite and Swipe with stats and costs; Rest with player-timed vulnerability/recovery; functioning HP/Stamina bars, victory/defeat and restart; continuous autonomous AI movement; server-owned combat and visible attack telegraphs. Do not implement the DNA puzzle, scanner, persistence, extra species, open-world island or encounter generation in this phase.
