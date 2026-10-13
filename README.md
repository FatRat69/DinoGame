# DinoGame — Codex Starter v3

This repository contains the design documents and a **Phase 0-1 Roblox real-time dinosaur-command prototype** in typed Luau. One flat arena hosts a player-commanded placeholder Deinonychus and an autonomous Gallimimus. Stances, Bite, Swipe, vulnerable manual Rest, HP/stamina, hit/miss feedback, victory/defeat and restart are implemented. All tuning is original and provisional.

## Open the prototype

On the development machine, a built place is available at `build/DinoGame.rbxlx`. In Roblox Studio, use **File > Open from File**, select that file, and press **Play** (F5), not Run. The arena is created by the server when a player joins. The human is a stationary communication-controller operator; no character or WASD dinosaur steering is used.

Each test player gets an isolated arena and encounter. The four stance buttons change autonomous movement. Bite/Swipe buttons display Damage, Effort and Accuracy and are enabled only when the server reports that the action is legal. Hover over an action to see range/timing. Rest commits the dinosaur for 2.4 seconds, restores stamina and increases incoming damage. Complete the battle, then use Restart Encounter.

The camera follows behind the ally's rear quarter at a low angle, framing both dinosaurs rather than the entire arena. Zoom adjusts automatically to their separation and actual model bounds. Mouse wheel or the controller's **+ / -** buttons adjust zoom within safe full-body limits. Restart restores automatic zoom. Names remain in the color-matched HUD; floating names have been removed. Result/restart overlays occupy the inactive controller area after a battle so the dinosaurs remain visible.

See [camera behavior and testing](docs/CAMERA.md). This camera revision changes no combat tuning and does not begin Phase 2.

These steps do not require a Rojo Studio plugin. A fresh clone needs the build step below to generate its place file. Generated places and local downloaded tools are intentionally ignored by Git.

## Build and test

Required development tools: **Rojo 7.7.1** and the official **Luau 0.742** CLI suite (`luau`, `luau-analyze`, `luau-compile`). These tools build/check the project; there are no third-party game runtime dependencies. Download the appropriate platform binaries from [Rojo releases](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.1) and [Luau releases](https://github.com/luau-lang/luau/releases/tag/0.742), then put the executables on your PATH. `rokit.toml` records the versions for developers using Rokit.

From this repository directory, run:

```bash
make test
make check
make build
```

`make` also detects the `.tools/rojo/` and `.tools/luau/` binaries downloaded on this development machine. If `make` is unavailable, use the tool commands directly:

```bash
luau tests/combat.spec.luau
luau tests/camera.spec.luau
luau-analyze src/shared/Config.luau src/shared/Combat.luau src/client/CameraMath.luau tests/combat.spec.luau tests/camera.spec.luau
mkdir -p build
rojo build default.project.json -o build/DinoGame.rbxlx
```

On Windows, use Git Bash for `make`/`mkdir -p`, or run the individual Luau commands in PowerShell and create the build directory with `New-Item -ItemType Directory -Force build` before the Rojo command. No paid plugins, imported art or asset IDs are needed.

The rules suite checks legality, stamina, range/facing at impact, accuracy, attack phases/cooldowns, Rest vulnerability, rate limits, autonomous stances, terminal states, clean resets, deterministic replay and 20 seeded simulated battles. Camera tests cover projection fitting, different sizes/aspects, separation, smoothing and angle wrap. The standalone analyzer checks the pure modules and their tests; `make check` syntax-compiles every runtime/test file. Roblox API type checking must be checked in Studio. The two `tests/studio-*.spec.luau` scripts run through Studio's Client Command Bar during Play, as explained in CAMERA.md. Simulated battles do **not** satisfy the human playtest gate.

## Edit with live Studio synchronization

1. Open `build/DinoGame.rbxlx` in Studio, or create a separate empty Baseplate place.
2. Install the matching **Rojo 7** Studio plugin via `rojo plugin install` or the [official installation guide](https://rojo.space/docs/v7/getting-started/installation/).
3. Run `make serve` (or `rojo serve default.project.json`) from the repo. Rojo defaults to localhost port 34872.
4. In Studio's Rojo plugin, connect to localhost:34872, review the sync changes, and sync this project.
5. Stop and restart Play after changing server/shared modules. Keep durable code changes in `src/`; rebuilding overwrites generated place files.
6. Commit source/config/docs through Git. Do not commit tool binaries or generated builds. The prototype and camera revision are proposed through a pull request for collaborator review.

See [the manual playtest checklist](docs/PLAYTEST_CHECKLIST.md) before approving Phase 2.

## Source layout and authority

- `src/shared/Config.luau`: provisional species, skill, stance, Rest and rate-limit settings.
- `src/shared/Combat.luau`: deterministic fixed-step state machine, scalar positions, hit RNG, AI and legal-command rules.
- `src/server/Arena.luau`: flat arena and original block-built placeholder dinosaurs.
- `src/server/Main.server.luau`: per-player encounters, server-owned simulation and replication, remote validation and clean restart.
- `src/client/Main.client.luau`: responsive controller, server-fed status, intent-only buttons and camera/zoom wiring.
- `src/client/BattleCamera.luau`: smooth rear-quarter battle framing and environment/model collision protection.
- `src/client/CameraMath.luau`: pure projection and damping calculations.
- `tests/combat.spec.luau`: standalone reproducible rule tests.
- `tests/camera.spec.luau` and `tests/studio-*.spec.luau`: camera math and Studio regression checks.
- `default.project.json`: Rojo mapping into Roblox services.

The client sends only `{kind, value, encounterId}`. The server rejects unexpected keys, unknown actions, invalid types, stale encounter IDs and excess traffic. HP, stamina, positions, facing, hit/miss, cooldowns and AI are server-owned. The token bucket persists across restarts; no queued attacks can spill into the next encounter. Only completed encounters can restart.

Combat RNG is seeded per encounter and the server logs the user, encounter ID and seed. To replay one in Studio, stop Play and set a numeric `DinoTestSeed` attribute on Workspace, then Play again. Identical seeds require identical command timing to reproduce identical outcomes. There are no reward or encounter-spawn RNG systems in this phase.

## Review status

Implemented Phase 0 and Phase 1 only. Automated checks, the local build and live Studio tests are reported in `docs/VERIFICATION.md`. The cinematic camera has been checked across all four stances, attack/Rest phases, both outcomes, restarts, differently sized visual fixtures, wall/terrain obstructions and simulated viewport sizes. Actual mobile device/emulator interaction, multiple clients and the full human testing gate remain pending. No DNA, rewards, island, saves, armor systems or other later-phase mechanics are implemented.

## Read in order
1. [Game design brief](GAME_DESIGN_BRIEF.md): approved gameplay pillars and expressly unresolved design.
2. [Implementation plan](IMPLEMENTATION_PLAN.md): eight development phases and Studio playtest gates.
3. [Codex instructions](AGENTS.md): coding and scope rules.
4. [First Codex prompt](CODEX_START_PROMPT.md): exactly what to ask Codex to implement first.

## Next development step
Build/open the place and complete the Phase 1 Studio checklist **before** approving Phase 2. The original first prompt remains in CODEX_START_PROMPT.md as the scope reference.

## Current v3 gameplay decisions
Combat is real-time, command-driven 1v1, not WASD or turn-based. The roster targets twelve playable dinosaurs, max five owned per run, max five equipped attacks each. Learning opportunities are random, **hidden and irreversibly consumed by victories**; reward formidability, relative threat and compatibility are separate. Large dinosaurs greatly outperform small ones in direct combat, while small dinosaurs enable narrow/fragile-ground exploration. Ankylosaurus armored areas resist normal attacks and rare named Piercing/Crushing moves counter them. Island geography is fixed, with random unscripted opponent spawns and fixed story encounters. On a new run **all mechanical power resets**; only observed species/skills and story knowledge persist in the journal. No advance eligibility scanner is planned.

See CHANGELOG.md for version history. All precise balance numbers and unresolved abilities are provisional until designed and playtested.
