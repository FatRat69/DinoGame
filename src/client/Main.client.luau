--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("DinoShared"):WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("DinoRemotes")
local command = remotes:WaitForChild("Command") :: RemoteEvent
local state = remotes:WaitForChild("State") :: RemoteEvent
local BattleCamera = require(script.Parent:WaitForChild("BattleCamera"))
local battleCamera = BattleCamera.new()

local colors = {
    surface = Color3.fromRGB(25, 31, 33), raised = Color3.fromRGB(43, 51, 53),
    text = Color3.fromRGB(243, 247, 247), muted = Color3.fromRGB(179, 193, 195),
    ally = Color3.fromRGB(59, 205, 175), enemy = Color3.fromRGB(237, 133, 147),
    stamina = Color3.fromRGB(241, 206, 104), selected = Color3.fromRGB(51, 107, 95),
}

local gui = Instance.new("ScreenGui")
gui.Name = "DinoController"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function frame(parent: Instance, name: string, size: UDim2, position: UDim2, color: Color3): Frame
    local item = Instance.new("Frame")
    item.Name = name
    item.Size = size
    item.Position = position
    item.BackgroundColor3 = color
    item.BorderSizePixel = 0
    item.Parent = parent
    return item
end

local function label(parent: Instance, text: string, size: UDim2, position: UDim2, fontSize: number, color: Color3): TextLabel
    local item = Instance.new("TextLabel")
    item.Size = size
    item.Position = position
    item.BackgroundTransparency = 1
    item.Text = text
    item.TextColor3 = color
    item.TextSize = fontSize
    item.Font = Enum.Font.GothamMedium
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextWrapped = true
    item.Parent = parent
    return item
end

local function button(parent: Instance, name: string, size: UDim2, position: UDim2): TextButton
    local item = Instance.new("TextButton")
    item.Name = name
    item.Size = size
    item.Position = position
    item.BackgroundColor3 = colors.raised
    item.TextColor3 = colors.text
    item.Text = name
    item.TextSize = 13
    item.Font = Enum.Font.GothamMedium
    item.TextWrapped = true
    item.AutoButtonColor = false
    item.BorderSizePixel = 0
    item.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = item
    return item
end

local top = frame(gui, "Combatants", UDim2.new(1, -24, 0, 106), UDim2.fromOffset(12, 8), colors.surface)
local topLimit = Instance.new("UISizeConstraint")
topLimit.MaxSize = Vector2.new(900, 106)
topLimit.Parent = top
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 8)

local function combatantPanel(offset: number, name: string, role: string, color: Color3)
    local panel = frame(top, role, UDim2.new(0.5, -18, 1, -16), UDim2.new(offset, 12, 0, 8), colors.surface)
    local title = label(panel, name, UDim2.new(1, 0, 0, 22), UDim2.fromOffset(0, 0), 17, color)
    local phaseLabel = label(panel, role, UDim2.new(1, 0, 0, 15), UDim2.fromOffset(0, 22), 11, colors.muted)
    local hpText = label(panel, "HP", UDim2.new(1, 0, 0, 17), UDim2.fromOffset(0, 37), 11, colors.text)
    local hpTrack = frame(panel, "Health", UDim2.new(1, 0, 0, 6), UDim2.fromOffset(0, 54), colors.raised)
    local hpFill = frame(hpTrack, "Fill", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), color)
    local staminaText = label(panel, "Stamina", UDim2.new(1, 0, 0, 17), UDim2.fromOffset(0, 64), 11, colors.text)
    local staminaTrack = frame(panel, "Stamina", UDim2.new(1, 0, 0, 6), UDim2.fromOffset(0, 81), colors.raised)
    local staminaFill = frame(staminaTrack, "Fill", UDim2.fromScale(1, 1), UDim2.fromOffset(0, 0), colors.stamina)
    return { title = title, phase = phaseLabel, hpText = hpText, hpFill = hpFill, staminaText = staminaText, staminaFill = staminaFill }
end
local allyPanel = combatantPanel(0, "Deinonychus", "PLAYER ALLY", colors.ally)
local enemyPanel = combatantPanel(0.5, "Gallimimus", "ENEMY AI", colors.enemy)

local controls = frame(gui, "Controller", UDim2.new(1, -24, 0, 228), UDim2.new(0.5, 0, 1, -12), colors.surface)
controls.AnchorPoint = Vector2.new(0.5, 1)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(900, 228)
limit.Parent = controls
local heading = label(controls, "COMMUNICATION CONTROLLER", UDim2.new(1, -90, 0, 20), UDim2.fromOffset(12, 7), 11, colors.muted)
local zoomOut = button(controls, "-", UDim2.fromOffset(28, 24), UDim2.new(1, -72, 0, 4))
local zoomIn = button(controls, "+", UDim2.fromOffset(28, 24), UDim2.new(1, -40, 0, 4))
zoomOut.Name, zoomIn.Name = "ZoomOut", "ZoomIn"
zoomOut.Activated:Connect(function() battleCamera:adjustZoom(0.12) end)
zoomIn.Activated:Connect(function() battleCamera:adjustZoom(-0.12) end)
local status = label(controls, "Connecting...", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 191), 12, colors.text)

local encounterId = 0
local latest: any = nil
local lastSequence = 0
local noticeUntil = 0
local latestFeedback = "Encounter ready"
local stanceButtons: { [string]: TextButton } = {}

local function send(kind: string, value: string?)
    command:FireServer({ kind = kind, value = value, encounterId = encounterId })
end

for index, stance in Config.Stances do
    local item = button(controls, stance, UDim2.new(0.25, -15, 0, 36), UDim2.new((index - 1) / 4, 12, 0, 32))
    stanceButtons[stance] = item
    item.Activated:Connect(function()
        if latest and not latest.outcome and latest.ally.phase == "Idle" then send("Stance", stance) end
    end)
end

type MoveView = { button: TextButton, name: TextLabel, availability: TextLabel, stats: TextLabel }
local moveButtons: { [string]: MoveView } = {}
local tooltip = label(gui, "", UDim2.fromOffset(292, 82), UDim2.fromOffset(0, 0), 12, colors.text)
tooltip.BackgroundColor3 = colors.surface
tooltip.BackgroundTransparency = 0.02
tooltip.TextXAlignment = Enum.TextXAlignment.Center
tooltip.ZIndex = 10
tooltip.Visible = false
for _, entry in { { button = zoomIn, name = "Zoom in" }, { button = zoomOut, name = "Zoom out" } } do
    entry.button.MouseEnter:Connect(function()
        tooltip.Text = entry.name
        tooltip.AnchorPoint = Vector2.new(0.5, 1)
        tooltip.Position = UDim2.new(0.5, 0, 0, controls.AbsolutePosition.Y - 8)
        tooltip.Visible = true
    end)
    entry.button.MouseLeave:Connect(function() tooltip.Visible = false end)
end
UserInputService.InputChanged:Connect(function(input: InputObject, processed: boolean)
    if not processed and input.UserInputType == Enum.UserInputType.MouseWheel and not UserInputService:GetFocusedTextBox() then
        battleCamera:adjustZoom(-input.Position.Z * 0.1)
    end
end)

for index, id in { "Bite", "Swipe", "Rest" } do
    local item = button(controls, id, UDim2.new(1 / 3, -16, 0, 108), UDim2.new((index - 1) / 3, 12, 0, 76))
    item.Text = ""
    local name = label(item, id, UDim2.new(1, -12, 0, 22), UDim2.fromOffset(6, 5), 17, colors.text)
    local availability = label(item, "Waiting", UDim2.new(1, -12, 0, 22), UDim2.fromOffset(6, 27), 11, colors.muted)
    local move = Config.Skills[id]
    local stats = label(item,
        if move then string.format("Damage %d\nEffort %d\nAccuracy %d%%", move.damage, move.effort, math.floor(move.accuracy * 100))
        else string.format("+%d stamina/s\n%.1fs rest\nVulnerable", Config.RestRecovery, Config.RestDuration),
        UDim2.new(1, -12, 0, 49), UDim2.fromOffset(6, 52), 11, colors.text)
    moveButtons[id] = { button = item, name = name, availability = availability, stats = stats }
    item.Activated:Connect(function()
        if not latest or latest.outcome then return end
        if id == "Rest" then
            if latest.ally.phase == "Idle" and latest.ally.stamina < latest.ally.maxStamina then send("Rest", nil) end
        elseif latest.attacks[id].ready then send("Attack", id) end
    end)
    item.MouseEnter:Connect(function()
        if move then
            tooltip.Text = string.format("%s | Range %.1f studs\nWindup %.2fs | Strike %.2fs\nRecovery %.2fs | Cooldown %.1fs", id, move.range, move.windup, move.strike, move.recovery, move.cooldown)
        else
            tooltip.Text = string.format("Rest | %.1fs commitment\nIncoming damage x%.1f\nMovement and attacks unavailable", Config.RestDuration, Config.RestDamageMultiplier)
        end
        tooltip.AnchorPoint = Vector2.new(0.5, 1)
        tooltip.Position = UDim2.new(0.5, 0, 0, controls.AbsolutePosition.Y - 8)
        tooltip.Visible = true
    end)
    item.MouseLeave:Connect(function() tooltip.Visible = false end)
end

local overlay = frame(gui, "EncounterResult", UDim2.fromOffset(288, 176), UDim2.fromScale(0.5, 0.42), colors.surface)
overlay.AnchorPoint = Vector2.new(0.5, 0.5)
overlay.ZIndex = 20
overlay.Visible = false
local resultTitle = label(overlay, "Victory", UDim2.new(1, -32, 0, 40), UDim2.fromOffset(16, 12), 25, colors.ally)
local resultDetails = label(overlay, "", UDim2.new(1, -32, 0, 40), UDim2.fromOffset(16, 54), 13, colors.muted)
local restart = button(overlay, "Restart Encounter", UDim2.new(1, -32, 0, 44), UDim2.fromOffset(16, 114))
restart.Activated:Connect(function() send("Restart", nil) end)

local function updatePanel(panel: any, f: any, role: string)
    panel.title.Text = f.name
    panel.phase.Text = role .. " | " .. f.phase
    panel.hpText.Text = string.format("HP %d / %d", math.ceil(f.hp), f.maxHp)
    panel.hpFill.Size = UDim2.fromScale(math.clamp(f.hp / f.maxHp, 0, 1), 1)
    panel.staminaText.Text = string.format("Stamina %d / %d", math.floor(f.stamina), f.maxStamina)
    panel.staminaFill.Size = UDim2.fromScale(math.clamp(f.stamina / f.maxStamina, 0, 1), 1)
end

state.OnClientEvent:Connect(function(snapshot: any)
    if snapshot.encounterId ~= encounterId then
        encounterId = snapshot.encounterId
        lastSequence = 0
        latestFeedback = "Encounter ready"
        noticeUntil = 0
        battleCamera:reset()
    end
    latest = snapshot
    updatePanel(allyPanel, snapshot.ally, "ALLY")
    updatePanel(enemyPanel, snapshot.enemy, "AI")
    for stance, item in stanceButtons do
        local active = stance == snapshot.ally.stance
        item.BackgroundColor3 = if active then colors.selected else colors.raised
        item.TextColor3 = if active then colors.ally else colors.text
        item.Active = not snapshot.outcome and snapshot.ally.phase == "Idle"
    end
    for id, view in moveButtons do
        local ready, reason = false, ""
        if id == "Rest" then
            ready = not snapshot.outcome and snapshot.ally.phase == "Idle" and snapshot.ally.stamina < snapshot.ally.maxStamina
            reason = if snapshot.outcome then "Finished" elseif snapshot.ally.phase ~= "Idle" then snapshot.ally.phase elseif not ready then "Stamina full" else "Ready"
        else
            local attack = snapshot.attacks[id]
            ready, reason = attack.ready, attack.reason
            if reason == "Cooldown" then reason = string.format("Cooldown %.1fs", attack.cooldown) end
        end
        view.availability.Text = reason
        view.button.BackgroundColor3 = if ready then colors.selected else colors.raised
        view.name.TextColor3 = if ready then colors.ally else colors.muted
        view.button.Active = ready
    end
    for _, event in snapshot.events do
        if event.sequence > lastSequence then
            lastSequence = event.sequence
            if event.kind ~= "Windup" then latestFeedback = event.text end
        end
    end
    if snapshot.notice then
        noticeUntil = os.clock() + 1.5
        status.Text = snapshot.notice
    elseif os.clock() >= noticeUntil then
        status.Text = latestFeedback
    end
    overlay.Visible = snapshot.outcome ~= nil
    if snapshot.outcome then
        tooltip.Visible = false
        resultTitle.Text = snapshot.outcome
        resultTitle.TextColor3 = if snapshot.outcome == "Victory" then colors.ally else colors.enemy
        resultDetails.Text = string.format("Encounter completed in %.1fs\nDeinonychus HP %d", snapshot.time, math.ceil(snapshot.ally.hp))
    end
end)

local allyModel: Model? = nil
local enemyModel: Model? = nil
RunService:BindToRenderStep("DinoBattleCamera", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    camera.CameraType = Enum.CameraType.Scriptable
    local viewport = camera.ViewportSize
    local compact = viewport.X < 600
    local shortLandscape = viewport.Y < 540 and viewport.X > viewport.Y
    if shortLandscape then
        controls.AnchorPoint = Vector2.new(1, 1)
        controls.Position = UDim2.new(1, -12, 1, -12)
        controls.Size = UDim2.fromOffset(288, 228)
        top.AnchorPoint = Vector2.zero
        top.Position = UDim2.fromOffset(12, 8)
        top.Size = UDim2.new(1, -324, 0, 106)
    else
        controls.AnchorPoint = Vector2.new(0.5, 1)
        controls.Position = UDim2.new(0.5, 0, 1, -12)
        controls.Size = UDim2.new(1, -24, 0, 228)
        top.AnchorPoint = Vector2.new(0.5, 0)
        top.Position = UDim2.new(0.5, 0, 0, 8)
        top.Size = UDim2.new(1, -24, 0, 106)
    end
    overlay.Position = UDim2.fromOffset(controls.AbsolutePosition.X + controls.AbsoluteSize.X / 2, controls.AbsolutePosition.Y + controls.AbsoluteSize.Y / 2)
    allyPanel.title.TextSize = if compact then 14 else 17
    enemyPanel.title.TextSize = if compact then 14 else 17
    heading.TextSize = if compact then 10 else 11
    for _, item in stanceButtons do item.TextSize = if compact then 11 else 13 end
    local inset = GuiService:GetGuiInset()
    local availableTop = top.AbsolutePosition.Y + top.AbsoluteSize.Y + inset.Y + 12
    local availableBottom = if shortLandscape then viewport.Y - 12 else controls.AbsolutePosition.Y + inset.Y - 12
    local availableRight = if shortLandscape then controls.AbsolutePosition.X + inset.X - 12 else viewport.X - 12
    if not allyModel or not allyModel.Parent or not enemyModel or not enemyModel.Parent then
        local arenas = Workspace:FindFirstChild("DinoArenas")
        local arena = arenas and arenas:FindFirstChild("Encounter_" .. player.UserId)
        if arena then
            for _, child in arena:GetChildren() do
                if child:IsA("Model") then
                    if child:GetAttribute("CombatRole") == "ally" then allyModel = child end
                    if child:GetAttribute("CombatRole") == "enemy" then enemyModel = child end
                end
            end
        end
    end
    if allyModel and enemyModel then
        local rect: BattleCamera.Rect = {
            left = 2 * 24 / viewport.X - 1,
            right = 2 * (availableRight - 12) / viewport.X - 1,
            top = 2 * (availableTop + 8) / viewport.Y - 1,
            bottom = 2 * (availableBottom - 8) / viewport.Y - 1,
        }
        if rect.right > rect.left and rect.bottom > rect.top then
            battleCamera:update(camera, allyModel, enemyModel, rect, dt)
        end
    end
end)

send("Sync", nil)
