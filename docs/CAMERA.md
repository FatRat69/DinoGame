# Cinematic Phase 1 battle camera

The camera is behind and to the side of the player's dinosaur, with a default 12-degree downward angle and a 52-degree rear-quarter shoulder offset. It uses the two models' current oriented bounding boxes rather than species-specific heights or the arena footprint. The larger dinosaur remains visibly larger: camera code changes neither models' scale nor combat stats.

## Following and framing

The focus is between the two body centers, weighted slightly toward the ally. Facing uses the ally's forward direction and follows the shortest angular path. Exponential damping smooths focus, rotation and zoom independently of frame rate. Zoom out cannot lag behind the distance needed to keep both bodies visible; zoom in eases as the dinosaurs approach. The projection solver fits all sixteen bounding-box corners into the visible rectangle between the HUD panels, including Roblox's top-bar inset. Camera rendering is bound immediately after Roblox's default camera priority to avoid reading the previous shot during attack motion.

Mouse wheel and the controller's + / - buttons offer optional zoom. Zoom ranges from the current full-body fit distance to 1.8 times that distance; it cannot crop the dinosaurs merely to get closer. The default is 1.06 times the fit distance. Restart clears accumulated tracking and restores that default, immediately framing the new starting positions. Results keep following the stationary combatants as smoothing settles; the result panel appears over the inactive controller area.

## Collision behavior

A sphere sweep with a 0.65-stud radius checks the focus-to-camera boom against collidable scenery and Terrain. Combatant bodies are tested separately against padded oriented bounds, because these anchored prototype models intentionally do not collide physically. Alternate shoulder angles provide an unobstructed view when possible. Endpoint overlap/terrain checks prevent a sweep correction from placing the camera inside a model, wall or floor.

A fully enclosed space may not permit an unobstructed full-body shot. The fallback prioritizes physical clearance and the previous safe position; visibility can be reduced until a valid view becomes available. Such spaces need authored camera accommodations when exploration maps are designed. No exploration or enclosure systems are added here.

## Future models

Combat models expose stable `CombatRole` attributes: `ally` and `enemy`. The client locates those roles inside its own Encounter container; presentation names are not camera identifiers. Replacing a placeholder with a larger model does not require species-specific camera code. Keep decorative/helper parts outside the combat model bounds or they will expand the framing distance. For future rigging, animation bounds and very fast movement should be reviewed with the same regression tests. Camera calculations are client-only and never influence hit ranges or server-owned positions.

Camera-only settings live in `src/client/BattleCamera.luau`. Projection and frame-independent smoothing live in `src/client/CameraMath.luau`. Combat values remain in their original shared modules without camera tuning mixed into them.

## Reproduce the checks

1. Follow README.md to build/open or Rojo-sync the place.
2. Stop Play, add Workspace's numeric `DinoTestSeed` attribute with value `42`, then use Play (F5).
3. Open Studio's Command Bar and select the **Client** data model.
4. Run `tests/studio-camera.spec.luau` as a Command Bar script. It creates local temporary fixtures, uses the actual camera controller with simulated viewport dimensions, and checks 480 full-body samples, frame-by-frame approach/retreat/turning, 0.5x/1x/4x opponent visual scales, wall/terrain avoidance, ground clearance, zoom bounds and tracking reset. The script restores Terrain voxels and removes the fixtures even on a failed assertion. This is not device-emulator or touch-input verification.
5. Run `tests/studio-encounter-camera.spec.luau` in the same Client context. It issues ordinary server-validated intents, tests all four stances, waits for an idle-player defeat, restarts, drives attacks/Rest to a victory, and checks rendered body bounds against the real HUD after the camera update. It may take roughly 45 seconds. No HP or balance values are modified.
6. Click Restart Encounter after victory and check the fresh view/zoom. Remove the test seed attribute while stopped after testing.
7. Run `make test check build` locally for the pure math/rule tests, syntax compilation and final place build.

Human review still needs actual scroll/button/touch interactions, device-emulator screenshots, comfort during sustained Flanking and real future rigs. See PLAYTEST_CHECKLIST.md. The checks support the Phase 1 camera review; they do not approve Phase 2.
