# Phase 0-1 verification

## Current cinematic-camera revision

- Combat Config, Combat simulation and the server encounter controller were not changed by the camera revision. Existing combat tests still pass, including the same 20-seed result of 20 automated-policy victories.
- **17 standalone tests passed**: 13 combat and 4 camera tests. The camera projection suite checks 180 combinations of viewport aspect, HUD rectangle, separation and visual size; damping/frame-rate and angle-wrap checks pass.
- Strict analysis passed for pure combat/camera math modules and their tests. All runtime and test files syntax-compiled, and Rojo built the final place.
- Studio camera-controller tests passed **480 framing samples**, including 0.5x/1x/4x visual opponent sizes, five simulated viewport dimensions, minimum/maximum zoom and a continuous turning/separation trajectory. A small normalized projection tolerance accounts for Roblox float precision at the isolated test fixtures' coordinates.
- Temporary wall and actual Terrain obstructions triggered avoidance. Ground/model clearance, zoom clamps and tracking reset passed. Local test fixtures were removed and saved Terrain voxels restored.
- The final live integration test passed Offensive, Neutral, Defensive and Flanking; attack/Rest motion; idle-player Defeat; Restart after Defeat; and ordinary-intent Victory. All full-body corners remained between HUD panels at the rendered sample points. Default pitch stayed about 12 degrees and camera height stayed roughly 6-8 studs for these encounters.
- A separate Restart after Victory check restored health, hid the result panel and returned to the low-angle starting view.
- Desktop screenshots were inspected for body prominence, HUD visibility and result layout. Floating labels were removed; the HUD carries species identity and matching colors. Result overlays occupy the controller area.
- An initial action-timing crop was corrected by moving the camera to explicit render priority; the final action/encounter test passed after this change. Captured Studio console logs contained encounter seed logs and no runtime errors.
- The collaborator reported that the initial prototype's combat worked after human playtesting. This camera revision still needs their visual review; no 20-human-battle or 3-5-novice completion is inferred from that report.

The sections below preserve the earlier prototype checks as historical context; the overhead camera described there has been replaced.

## Executed locally

- Official Luau 0.742: **13 rule tests passed**.
- Twenty seeded automated command-policy battles completed, with 20 victories, no stalled AI, valid arena bounds and valid stamina/HP limits. This is a simple aggressive automated policy, not a balance claim or novice test.
- A separate idle-player scenario ended in defeat; both terminal states are covered.
- Strict Luau analysis passed for Config, Combat and the rule tests.
- Official Luau syntax compilation passed for all five runtime modules and the tests.
- Rojo 7.7.1 built `build/DinoGame.rbxlx` successfully.
- The downloaded Rojo and Luau archives matched the SHA-256 digests published on their official releases.

## Executed in Roblox Studio

- Opened the generated DinoGame place in a separate Studio window; the unrelated Grow A Monster place was not edited.
- Play created the arena, client HUD and Scriptable camera. Server Output reported the encounter seed, with no runtime errors in the captured log.
- A live idle-player encounter reached Defeat and displayed the outcome/restart overlay.
- Restart reset HP to 125/110, ally stamina to 100 and incremented the encounter ID.
- Client remote checks rejected a damage-bearing payload, an unknown attack and a stance command carrying the previous encounter ID. Enemy HP and ally stance remained unchanged by those commands.
- A live automated policy sent ordinary client attack/Rest intents against seed 42 and reached Victory at 10.9 simulation seconds, ally HP 47, with one Rest action.
- Desktop screenshots were inspected. An initial camera/HUD overlap was fixed; a subsequent projection check confirmed all four arena corners remained strictly between the HUD panels at an 833x744 viewport. Final screenshot and console output were inspected.
- Studio was returned to Edit mode and the test-only seed attribute was removed. The built file was regenerated from the final source.

## Not yet executed

Roblox API type analysis, actual mobile/landscape device-emulator interaction, multi-client isolation, sustained remote-flood tests, comfort with the revised camera and the complete human battle/testing gate remain pending. Simulated camera viewport fixtures do not constitute actual device/touch verification. See PLAYTEST_CHECKLIST.md. Automated policies and seeded simulations do not count as human review.

## Prototype limits

Block-built original placeholders, cinematic rear-quarter camera, one isolated arena per player, two shared attack definitions with species damage scaling, no persistence or progression. Seed and command timing reproduce combat only. All numerical combat values are provisional. Phase 2 and later remain gated on human review as requested by AGENTS.md.
