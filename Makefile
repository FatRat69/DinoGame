ROJO ?= $(if $(wildcard .tools/rojo/rojo),.tools/rojo/rojo,rojo)
LUAU ?= $(if $(wildcard .tools/luau/luau),.tools/luau/luau,luau)
ANALYZE ?= $(if $(wildcard .tools/luau/luau-analyze),.tools/luau/luau-analyze,luau-analyze)
COMPILE ?= $(if $(wildcard .tools/luau/luau-compile),.tools/luau/luau-compile,luau-compile)
SOURCES = src/shared/Config.luau src/shared/Combat.luau src/server/Arena.luau src/server/Main.server.luau src/client/CameraMath.luau src/client/BattleCamera.luau src/client/Main.client.luau tests/combat.spec.luau tests/camera.spec.luau tests/studio-camera.spec.luau tests/studio-encounter-camera.spec.luau

.PHONY: test check build serve
test:
	$(LUAU) tests/combat.spec.luau
	$(LUAU) tests/camera.spec.luau

check:
	$(ANALYZE) src/shared/Config.luau src/shared/Combat.luau src/client/CameraMath.luau tests/combat.spec.luau tests/camera.spec.luau
	$(COMPILE) --null $(SOURCES)

build:
	mkdir -p build
	$(ROJO) build default.project.json -o build/DinoGame.rbxlx

serve:
	$(ROJO) serve default.project.json
