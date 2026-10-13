# Codex working rules — DinoGame v3

Read GAME_DESIGN_BRIEF.md and IMPLEMENTATION_PLAN.md before editing; treat v3 decisions as authoritative over superseded design drafts.

## Work one phase at a time
First task is **Phase 0 and Phase 1 ONLY**, then STOP for human review. Inspect the repository, summarize changes before writing, keep unrelated work untouched, and clearly report tests that actually ran versus manual Studio tests still required.

## Technical standards
- Original Roblox project in typed Luau; prefer Rojo-compatible src/shared, src/server and src/client plus documented Studio sync/setup. Do not add third-party dependencies without explaining/approving them.
- Use small, data-driven modules, stable species/skill/encounter IDs, configurable provisional balance values and deterministic, testable calculations.
- **Server-authoritative** HP, stamina, positions used in hits, accuracy rolls, command eligibility, cooldowns, reward RNG, inventory and save states. Clients send stance/skill or DNA placement **intents**, not damage, hit confirmation or unlocked skills. Reject illegal/rate-limited commands.
- Seed reward and encounter RNG per run and log seed/reward inputs for replay/debug. Never silently fake results or claim Studio playtesting was performed by static checks.
- No borrowed Jurassic Park art, logos, characters, source code or in-game branding.

## Gameplay invariants for later phases
- One-on-one real-time autonomous movement with Offensive/Neutral/Defensive/Flanking stances and player-timed Rest; skill UI shows Damage/Effort/Accuracy.
- Enemy learning opportunities are hidden and irreversibly consumed; **NO skill-eligibility scanner**. Reward factors separate opponent intrinsic formidability, relative threat and broadly permissive compatibility. Trivial battles give no build progression.
- Large dinosaurs are decisively stronger in combat; smaller dinosaurs matter for exploration and are usually faster/more evasive/stamina efficient. Do not force equal win rates. Run-only upgrades cannot erase size hierarchy.
- Ankylosaurus armored regions block ordinary damage; rare explicitly named Piercing/Crushing attacks bypass armor. Coverage and mandatory counter paths are not finalized.
- Static island landscape across runs, seeded enemy counts/locations at vetted nodes plus required scripted encounters.
- Every run starts with Deinonychus or Gallimimus; max five dinosaurs and five equipped attacks per dinosaur. Every form of power resets on new run. Persist only observed species/story/skill journal knowledge.
- Parasaurolophus chip-signal detection is an unapproved possible fiction, NEVER a predictor of learnability.

## Phase 1 task limits
Only one flat arena, player-commanded placeholder Deinonychus vs AI Gallimimus, four visible posture controls, Bite/Swipe/manual Rest, HP/Stamina and move Damage/Effort/Accuracy, server-owned attacks, AI approach/flanking/retreat, hit/miss, win/loss, restart. Do not start DNA, randomized rewards, exploration, save/journal, giant animal armor, polished rigs, maps, cinematics or monetization.
