# Exact first prompt for Codex — Phase 0 and Phase 1

Read AGENTS.md, GAME_DESIGN_BRIEF.md and IMPLEMENTATION_PLAN.md in this repository completely. Inspect the repository and briefly outline your plan before editing.

Implement **PHASE 0 AND PHASE 1 ONLY** of an original Roblox dinosaur-command game, in typed Luau with a Rojo-compatible project and documented Roblox Studio setup.

A human operates a communication controller, selecting a stance and attack for a dinosaur which moves autonomously. Build a single flat arena containing a clearly labeled **Deinonychus (player ally)** and **Gallimimus (enemy AI)** as simple placeholder models. Combat runs continuously: **NO turn-based combat and NO player WASD steering of the dinosaur**.

Offer four posture controls: Offensive (approach), Neutral (hold spacing), Defensive (withdraw), Flanking (seek side/rear). Add Bite, Swipe and manually activated, vulnerable **Rest**. Attacks must have visible provisional **Damage, Effort, Accuracy**, range, windup, recovery, cooldown and legal stance checks. Server validates commands and owns HP/Stamina, hit/miss and cooldowns; client sends only intents. Enemy AI continuously repositions/attacks. Show both combatants' HP and stamina, attack feedback, win/lose overlay and Restart Encounter. Include rate-limits, simple reproducible rules tests and a manual Roblox Studio playtest checklist.

Do **NOT** code DNA puzzles, skill learning, scan goggles, journal saves, giant dinosaur balancing, Ankylosaurus armor, exploration islands, randomized encounter placements, additional rigs, monetization or story cutscenes in this task. Later phases include irreversible hidden rewards, size-dominant combat and knowledge-only persistence; don't prematurely invent their unresolved numeric formulas.

Report changed files, actual tests run, honest limitations and precise steps to launch the result in Roblox Studio. **STOP after Phase 1** for collaborator review.
