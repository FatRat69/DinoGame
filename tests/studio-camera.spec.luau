--!strict
-- Run in Studio's CLIENT Command Bar during Play, or through execute_luau (Client).
-- Temporary local fixtures never change the server's combatants or tuning.
local player = game:GetService("Players").LocalPlayer
assert(player, "Run in the Client data model during Play")
local BattleCamera = require(player.PlayerScripts.DinoClient.BattleCamera)
local source = workspace.DinoArenas:FindFirstChild("Encounter_" .. player.UserId)
assert(source, "The player's encounter must exist")
local fixture = Instance.new("Folder")
fixture.Name = "CameraTestFixtures"
local origin = Vector3.new(10000, 0, 0)
local floor = Instance.new("Part")
floor.Anchored = true
floor.Size = Vector3.new(400, 1, 400)
floor.Position = origin - Vector3.yAxis * 0.5
floor.Parent = fixture
local ally = source.Deinonychus:Clone()
local enemy = source.Gallimimus:Clone()
ally.Parent, enemy.Parent = fixture, fixture
fixture.Parent = workspace

local function pose(model: Model, position: Vector3, yaw: number, scale: number)
    model:ScaleTo(scale)
    model:PivotTo(CFrame.new(position) * CFrame.Angles(0, yaw, 0))
    local cf, size = model:GetBoundingBox()
    model:PivotTo(model:GetPivot() + Vector3.yAxis * (0.2 - (cf.Position.Y - size.Y / 2)))
end

local function verify(camera: any, rect: BattleCamera.Rect)
    local tanV = math.tan(math.rad(camera.FieldOfView / 2))
    local aspect = camera.ViewportSize.X / camera.ViewportSize.Y
    for _, model in { ally, enemy } do
        local cf, size = model:GetBoundingBox()
        local localCamera = cf:PointToObjectSpace(camera.CFrame.Position)
        local half = size / 2 + Vector3.one * 0.65
        assert(math.abs(localCamera.X) > half.X or math.abs(localCamera.Y) > half.Y or math.abs(localCamera.Z) > half.Z, "Camera inside dinosaur bounds")
        for _, x in { -1, 1 } do for _, y in { -1, 1 } do for _, z in { -1, 1 } do
            local p = camera.CFrame:PointToObjectSpace(cf:PointToWorldSpace(size * Vector3.new(x, y, z) / 2))
            assert(-p.Z > 0, "Body behind camera")
            local sx, sy = p.X / (-p.Z * tanV * aspect), -p.Y / (-p.Z * tanV)
            assert(sx >= rect.left - 0.001 and sx <= rect.right + 0.001, "Horizontal cropping")
            assert(sy >= rect.top - 0.001 and sy <= rect.bottom + 0.001, string.format("HUD cropping: y=%.5f bounds=[%.5f,%.5f]", sy, rect.top, rect.bottom))
        end end end
    end
    assert(camera.CFrame.Position.Y > 0.65, "Camera below ground clearance")
end

local checked = 0
local terrainRegion: Region3? = nil
local terrainMaterials: any = nil
local terrainOccupancy: any = nil
local ok, failure = pcall(function()
    for _, viewport in { Vector2.new(1347, 744), Vector2.new(833, 744), Vector2.new(375, 812), Vector2.new(320, 568), Vector2.new(843, 390) } do
        local landscape = viewport.Y < 540 and viewport.X > viewport.Y
        local rect: BattleCamera.Rect = {
            left = 2 * 24 / viewport.X - 1,
            right = 2 * (if landscape then viewport.X - 324 else viewport.X - 24) / viewport.X - 1,
            top = 2 * 192 / viewport.Y - 1,
            bottom = 2 * (if landscape then viewport.Y - 12 else viewport.Y - 260) / viewport.Y - 1,
        }
        local camera: any = { ViewportSize = viewport }
        for _, size in { 0.5, 1, 4 } do
            for _, separation in { 3, 12, 40 } do
                for _, yaw in { 0, math.pi / 2, math.pi, -math.pi / 2 } do
                    pose(ally, origin + Vector3.new(-separation / 2, 3, 0), yaw, 1)
                    pose(enemy, origin + Vector3.new(separation / 2, 3, 0), -yaw, size)
                    for _, zoom in { 1, 1.8 } do
                        local controller = BattleCamera.new()
                        controller.zoom = zoom
                        controller:update(camera, ally, enemy, rect, 1 / 60)
                        verify(camera, rect)
                        checked += 1
                    end
                end
            end
            task.wait()
        end
    end

    local camera: any = { ViewportSize = Vector2.new(1347, 744) }
    local rect: BattleCamera.Rect = { left = -0.95, right = 0.95, top = -0.45, bottom = 0.35 }
    local controller = BattleCamera.new()
    for frame = 1, 120 do
        local separation = 4 + 25 * math.sin(frame / 120 * math.pi)
        local yaw = frame / 120 * math.pi * 2
        pose(ally, origin + Vector3.new(-separation / 2, 3, 0), yaw, 1)
        pose(enemy, origin + Vector3.new(separation / 2, 3, 0), -yaw, 1)
        controller:update(camera, ally, enemy, rect, 1 / 60)
        verify(camera, rect)
        checked += 1
        if frame % 30 == 0 then task.wait() end
    end

    pose(ally, origin + Vector3.new(-4, 3, 0), math.pi / 2, 1)
    pose(enemy, origin + Vector3.new(4, 3, 0), -math.pi / 2, 1)
    controller:reset()
    controller:update(camera, ally, enemy, rect, 1 / 60)
    local original = camera.CFrame.Position
    local focus = controller.focus :: Vector3
    local wall = Instance.new("Part")
    wall.Name = "CameraObstruction"
    wall.Anchored = true
    wall.Size = Vector3.new(8, 18, 1)
    wall.CFrame = CFrame.lookAt(focus:Lerp(original, 0.65), focus)
    wall.Parent = fixture
    controller:reset()
    controller:update(camera, ally, enemy, rect, 1 / 60)
    verify(camera, rect)
    assert((camera.CFrame.Position - original).Magnitude > 2, "Camera did not avoid wall")
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { ally, enemy }
    params.RespectCanCollide = true
    assert(workspace:Spherecast(controller.focus :: Vector3, 0.65, camera.CFrame.Position - (controller.focus :: Vector3), params) == nil, "Camera intersects obstruction")
    wall:Destroy()

    local rockPosition = focus:Lerp(original, 0.65)
    terrainRegion = Region3.new(rockPosition - Vector3.one * 20, rockPosition + Vector3.one * 20):ExpandToGrid(4)
    terrainMaterials, terrainOccupancy = workspace.Terrain:ReadVoxels(terrainRegion, 4)
    workspace.Terrain:FillBlock(CFrame.new(rockPosition), Vector3.new(8, 18, 8), Enum.Material.Rock)
    controller:reset()
    controller:update(camera, ally, enemy, rect, 1 / 60)
    verify(camera, rect)
    assert(workspace:Spherecast(controller.focus :: Vector3, 0.65, camera.CFrame.Position - (controller.focus :: Vector3), params) == nil, "Camera intersects terrain obstruction")

    controller:adjustZoom(100)
    assert(controller.zoom == 1.8)
    controller:adjustZoom(-100)
    assert(controller.zoom == 1)
    controller:reset()
    assert(controller.zoom == 1.06 and controller.position == nil and controller.focus == nil)
end)

fixture:Destroy()
if terrainRegion then workspace.Terrain:WriteVoxels(terrainRegion, 4, terrainMaterials, terrainOccupancy) end
assert(ok, string.format("After %d samples: %s", checked, tostring(failure)))
return string.format("PASS: %d Studio camera framing samples, low/giant visual bounds, wall/terrain avoidance, floor clearance, zoom bounds and restart reset", checked)
