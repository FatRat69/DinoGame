# Prompt to paste into Codex

You are implementing an original dinosaur-command adventure in **Roblox Studio / typed Luau**, using the project documents in this repository.

**Read `AGENTS.md`, `GAME_DESIGN_BRIEF.md`, and `IMPLEMENTATION_PLAN.md` completely before writing code.** Inspect the current repository, summarize your findings, provide a short plan, then implement **PHASE 0 AND PHASE 1 ONLY** and stop. Do not implement later-stage features now.

The core interaction is continuous **real-time** dinosaur command combat. The human player controls a recovered communication device, picks a stance and attack, and observes the allied dinosaur act autonomously against an AI opponent. It is NOT turn based; it is NOT a conventional WASD/action-control dinosaur fighter.

### Requirements for first playable prototype
1. Create a valid minimal Rojo-compatible project with `default.project.json`, `src/shared`, `src/server`, `src/client` and `README.md`, requiring as few external dependencies as possible. Explain exact Roblox Studio setup and test instructions.
2. Programmatically create a flat battle arena with two distinctly labeled, simple dinosaur-shaped placeholder rigs (or primitive multipart models), one player-commanded **Deinonychus** and one enemy AI **Gallimimus**.
3. Present UI buttons for **Offensive**, **Neutral**, **Defensive**, **Flanking**; the ally autonomously approaches, holds spacing, retreats or maneuvers to the enemy flank accordingly. All movement/decisions occur continuously; no turns. AI movement should avoid oscillation and overlapping models.
4. Add two attack skills **Bite** and **Swipe**, plus **Rest**. For each offensive skill show **Damage**, **Effort**, **Accuracy**, Range, Windup/Recovery/Cooldown. All starting numbers are explicit placeholder balance values. Allow skill only if owned, in usable stance, off cooldown, in reach at accepted resolution, with enough stamina, and combatant capable of attacking. Show accepted/rejected state to player.
5. Rest must be **player-triggered**, cause a vulnerable stationary period, and restore stamina (optional strictly limited HP), with clear visuals. Do not replace this with fully automatic regeneration. Small-bodied species' long-term advantages in stamina efficiency, attack speed and dodge are acknowledged in definitions but may be tested later.
6. Combat/rolls/cooldowns and position validation are **server authoritative**. Client sends posture/skill intent only. Add input validation, modest rate limiting, no client-sided damage confirmation.
7. Implement basic enemy target pursuit and attack selection with placeholder windup/strike/recovery animations. Show bars for both dinosaur Health and Stamina; render visible outcomes for hit/miss, damage and battle end, and a Restart Encounter button that fully resets combat state.
8. Provide a few deterministic tests for pure combat rules, and a manual checklist requiring validation in Studio. Run the tools you have and accurately state what is or isn't tested.

### Explicit exclusions
Do not build the permanent world map, procedural terrain, random opponent placement, analysis goggles, DNA puzzle, skill unlock RNG, run reset/save system, 12 dinosaur assets, premium animations, boss fights, monetization or cinematic story. Later, the world geography will remain identical between runs while opponent counts/locations vary. Discovered species and story/lore persist across runs; current team/skills/DNA reset. Keep future rules in docs, not half-implemented prototype modules.

### Acceptance criteria
- A collaborator can follow README, sync the code into Roblox Studio, click Play, and fight without hand-editing scripts.
- Ally moves continuously in response to all four stances while enemy behaves independently.
- Attack command inputs never pause the fight and fail safely if invalid or resource-starved.
- Manual Rest creates a strategic window with stamina recovered and risk of being attacked.
- Win/lose screen displays once, and Restart works repeatedly.
- The project has clear steps and report of tests run, limitations and next steps, and it stops after Phase 1.
