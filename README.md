# DinoGame — Codex Starter v3

This repository currently contains design and coding instructions for an **original Roblox real-time dinosaur-command adventure**, not finished playable code.

## Read in order
1. [Game design brief](GAME_DESIGN_BRIEF.md): approved gameplay pillars and expressly unresolved design.
2. [Implementation plan](IMPLEMENTATION_PLAN.md): eight development phases and Studio playtest gates.
3. [Codex instructions](AGENTS.md): coding and scope rules.
4. [First Codex prompt](CODEX_START_PROMPT.md): exactly what to ask Codex to implement first.

## First development step
Connect this GitHub repository to Codex, ask it to read the documents, and paste the contents of CODEX_START_PROMPT.md. Request Phase 0–1 only. Codex should scaffold the typed Luau project and document Git/Rojo/Studio synchronization. Follow those instructions to run and manually test the prototype **before** approving Phase 2.

## Current v3 gameplay decisions
Combat is real-time, command-driven 1v1, not WASD or turn-based. The roster targets twelve playable dinosaurs, max five owned per run, max five equipped attacks each. Learning opportunities are random, **hidden and irreversibly consumed by victories**; reward formidability, relative threat and compatibility are separate. Large dinosaurs greatly outperform small ones in direct combat, while small dinosaurs enable narrow/fragile-ground exploration. Ankylosaurus armored areas resist normal attacks and rare named Piercing/Crushing moves counter them. Island geography is fixed, with random unscripted opponent spawns and fixed story encounters. On a new run **all mechanical power resets**; only observed species/skills and story knowledge persist in the journal. No advance eligibility scanner is planned.

See CHANGELOG.md for version history. All precise balance numbers and unresolved abilities are provisional until designed and playtested.
