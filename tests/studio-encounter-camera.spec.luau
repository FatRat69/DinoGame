--!strict
-- Client Command Bar integration check. Plays real encounters using only ordinary intents.
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
assert(player, "Run in the Client data model during Play")
local remotes = game.ReplicatedStorage.DinoRemotes
local current: any = nil
local connection = remotes.State.OnClientEvent:Connect(function(state: any) current = state end)
local report = {}

local function waitFor(check: () -> boolean, seconds: number)
    local deadline = os.clock() + seconds
    repeat task.wait(0.1) until check() or os.clock() > deadline
    assert(check(), "Timed out waiting for encounter state")
end

local function sample()
    RunService.RenderStepped:Wait()
    local camera = workspace.CurrentCamera :: Camera
    local gui = player.PlayerGui.DinoController
    local inset = GuiService:GetGuiInset()
    local top = gui.Combatants.AbsolutePosition.Y + gui.Combatants.AbsoluteSize.Y + inset.Y
    local bottom = gui.Controller.AbsolutePosition.Y + inset.Y
    local arena = workspace.DinoArenas:FindFirstChild("Encounter_" .. player.UserId)
    assert(arena)
    for _, model in arena:GetChildren() do
        if not model:IsA("Model") then continue end
        local cf, size = model:GetBoundingBox()
        for _, x in { -1, 1 } do for _, y in { -1, 1 } do for _, z in { -1, 1 } do
            local point = camera:WorldToViewportPoint(cf:PointToWorldSpace(size * Vector3.new(x, y, z) / 2))
            assert(point.Z > 0 and point.X > 12 and point.X < camera.ViewportSize.X - 12, "Body cropped horizontally")
            assert(point.Y > top and point.Y < bottom, string.format("Body cropped by HUD: %s y=%.2f safe=[%.2f,%.2f] stance=%s phase=%s", model.Name, point.Y, top, bottom, current.ally.stance, current.ally.phase))
        end end end
        assert(model:FindFirstChildWhichIsA("BillboardGui", true) == nil, "Overlapping labels remain")
    end
    assert(camera.CFrame.Position.Y > 0.65, "Camera below floor")
    if current.outcome then
        assert(gui.EncounterResult.AbsolutePosition.Y + inset.Y >= bottom, "Result overlay covers the battle")
    end
    return { pitch = math.deg(math.asin(-camera.CFrame.LookVector.Y)), height = camera.CFrame.Position.Y, separation = current.distance }
end

local function send(kind: string, value: string?)
    remotes.Command:FireServer({ kind = kind, value = value, encounterId = current.encounterId })
end

local function restart()
    local id = current.encounterId
    send("Restart", nil)
    waitFor(function() return current.encounterId > id end, 3)
    assert(current.ally.hp == 125 and current.enemy.hp == 110 and current.ally.stamina == 100)
    task.wait(0.2)
    return sample()
end

local ok, failure = pcall(function()
    waitFor(function() return current ~= nil end, 3)
    if current.outcome then restart() end
    for _, stance in { "Offensive", "Neutral", "Defensive", "Flanking" } do
        waitFor(function() return current.ally.phase == "Idle" end, 3)
        send("Stance", stance)
        waitFor(function() return current.ally.stance == stance end, 3)
        task.wait(1.3)
        table.insert(report, { state = stance, camera = sample() })
    end
    send("Stance", "Offensive")
    waitFor(function() return current.outcome ~= nil end, 40)
    assert(current.outcome == "Defeat", "Idle player should lose")
    local before = (workspace.CurrentCamera :: Camera).CFrame
    task.wait(0.6)
    table.insert(report, { state = "Defeat", camera = sample() })
    assert(((workspace.CurrentCamera :: Camera).CFrame.Position - before.Position).Magnitude < 1, "Result camera keeps drifting")
    table.insert(report, { state = "RestartAfterDefeat", camera = restart() })

    local deadline = os.clock() + 40
    while not current.outcome and os.clock() < deadline do
        if current.ally.phase == "Idle" then
            if current.ally.stamina < 22 then send("Rest", nil)
            elseif current.attacks.Bite.ready then send("Attack", "Bite")
            elseif current.attacks.Swipe.ready then send("Attack", "Swipe") end
        end
        task.wait(0.15)
        sample()
    end
    assert(current.outcome == "Victory", "Attack policy did not win; use seed 42 for this regression")
    task.wait(0.6)
    table.insert(report, { state = "Victory", camera = sample() })
end)

connection:Disconnect()
assert(ok, tostring(failure))
return report
