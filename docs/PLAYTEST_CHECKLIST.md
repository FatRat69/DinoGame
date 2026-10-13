# Phase 0-1 Roblox Studio review

All checks below are pending human verification, including rechecking the automated Studio smoke checks recorded in VERIFICATION.md. Use Play (F5), not Run. Open Output and Script Analysis so errors are visible. Record failures, seed, commands, viewport and reproduction steps.

## Setup and arena

- [ ] Open the built place or sync into a separate empty place through Rojo 7.
- [ ] Play creates one flat arena with Deinonychus/Gallimimus placeholders clearly identified by their colors and HUD names, without floating-label overlap.
- [ ] Both HP/stamina displays and four stance/action controls appear without errors in Output or Script Analysis.
- [ ] The low-angle rear-quarter camera follows both full bodies; WASD cannot steer either dinosaur.
- [ ] Models remain above the arena, face their opponent and show windup/strike changes.

## Movement and attacks

- [ ] Offensive approaches; Neutral holds spacing; Defensive retreats; Flanking seeks the side/rear.
- [ ] The AI continuously approaches, flanks, attacks, withdraws and rests without freezing at the boundary.
- [ ] Bite and Swipe show provisional Damage/Effort/Accuracy, with range/timing available on hover.
- [ ] Attacks cost stamina once, visibly wind up, resolve at most once, recover, then respect cooldown.
- [ ] Targets moving outside range during windup can cause a miss. Hits and accuracy misses appear in feedback.
- [ ] Bite is unavailable in Defensive; Swipe remains legal there when the opponent is in range.
- [ ] Busy phases lock attacks/stance changes; rapid clicks do not queue or double-hit.
- [ ] Manual Rest recovers stamina, stops movement/attacks and makes incoming damage larger.
- [ ] Rest is unavailable at full stamina; depleted stamina disables unaffordable attacks.

## Results, replay and networking

- [ ] Win and loss both show the correct result, stop combat and offer Restart Encounter.
- [ ] Restart restores health/stamina, positions, stance, cooldowns, feedback and AI; repeat several times.
- [ ] Set Workspace's numeric DinoTestSeed attribute while stopped. Server Output reports that seed after Play/restart.
- [ ] In Studio's client Command Bar, try a forged command with a `damage` key; HP remains server-owned.

```lua
game.ReplicatedStorage.DinoRemotes.Command:FireServer({
    kind = "Attack", value = "Bite", encounterId = 1, damage = 99999,
})
```

- [ ] Send unknown attacks, wrong types, stale encounter IDs and rapid command bursts. Combat rejects them and stays responsive.
- [ ] Start a two-player local server. Each client controls only its own isolated encounter; one player's restart/disconnect does not alter the other's battle.
- [ ] Confirm each departing player's arena is removed.

## Layout and acceptance gate

- [ ] Camera keeps attacks/foot positioning prominent during all four stances; approach/retreat zoom and Flanking rotation feel comfortable.
- [ ] Camera remains outside models, floor and temporary scenery obstructions. Test larger visual rigs without changing combat tuning.
- [ ] Mouse-wheel and + / - zoom controls work; zoom in stops at full-body fit and restart restores the default.
- [ ] Victory/Defeat keep a stable low-angle view, and the result panel leaves the battle visible over the inactive controller area.

- [ ] Desktop: all controls, HP/stamina, feedback, labels and battle remain visible.
- [ ] Device Emulator at 375x812 and 320x568: labels fit, touch targets work and overlays do not overlap controls.
- [ ] Device Emulator in phone landscape: controller moves right, status stays left and combat is visible.
- [ ] Controller tooltips do not obscure outcome or persist after the mouse leaves.
- [ ] Complete about 20 **human-played** battles, covering both outcomes and all stances.
- [ ] Have 3-5 novice testers try the controller; note clarity of stance behavior, Rest decisions and rejected actions.
- [ ] Review tuning and findings with collaborators before approving Phase 2.

The automated 20-seed simulation tests are useful rule checks, not a replacement for these human Studio battles.
