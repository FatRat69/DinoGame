--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("DinoShared")
local Config = require(Shared:WaitForChild("Config"))
local Combat = require(Shared:WaitForChild("Combat"))
local Arena = require(script.Parent:WaitForChild("Arena"))

Players.CharacterAutoLoads = false

local remotes = Instance.new("Folder")
remotes.Name = "DinoRemotes"
local command = Instance.new("RemoteEvent")
command.Name = "Command"
command.Parent = remotes
local state = Instance.new("RemoteEvent")
state.Name = "State"
state.Parent = remotes
remotes.Parent = ReplicatedStorage

local arenas = Instance.new("Folder")
arenas.Name = "DinoArenas"
arenas.Parent = workspace

type Session = {
    encounter: Combat.Encounter, view: Arena.ArenaView,
    encounterId: number, lastSnapshot: number,
}
local sessions: { [Player]: Session } = {}
local nextSlot = 0

local function seedFor(player: Player): number
    -- Studio can set Workspace.DinoTestSeed for a reproducible encounter/restart.
    local override = workspace:GetAttribute("DinoTestSeed")
    if typeof(override) == "number" and override == override and math.abs(override) < 2147483647 then
        return math.floor(override)
    end
    return (DateTime.now().UnixTimestampMillis + player.UserId) % 2147483647
end

local function packed(f: Combat.Fighter)
    return {
        id = f.id, speciesId = f.species.id, name = f.species.name,
        hp = f.hp, maxHp = f.species.maxHp,
        stamina = f.stamina, maxStamina = f.species.maxStamina,
        stance = f.stance, phase = f.phase, skill = f.skill,
    }
end

local function snapshot(player: Player, session: Session, notice: string?)
    local e = session.encounter
    local attacks: { [string]: { ready: boolean, reason: string, cooldown: number } } = {}
    for id in Config.Skills do
        local ready, reason = Combat.canAttack(e, e.ally, e.enemy, id)
        attacks[id] = { ready = ready, reason = reason, cooldown = math.max(0, (e.ally.cooldowns[id] or 0) - e.time) }
    end
    state:FireClient(player, {
        encounterId = session.encounterId, seed = e.seed, time = e.time,
        ally = packed(e.ally), enemy = packed(e.enemy), attacks = attacks,
        events = e.events, outcome = e.outcome, notice = notice,
        center = session.view.center, distance = Combat.distance(e.ally, e.enemy),
    })
end

local function draw(session: Session)
    local e, view = session.encounter, session.view
    for _, id in { "ally", "enemy" } do
        local f = if id == "ally" then e.ally else e.enemy
        local model = if id == "ally" then view.ally else view.enemy
        Arena.update(model, view.center, f.x, f.z, f.yaw, f.phase, f.hp)
    end
end

local function addPlayer(player: Player)
    if sessions[player] then return end
    nextSlot += 1
    local view = Arena.create(arenas, Vector3.new((nextSlot - 1) * 150, 0, 0), "Encounter_" .. player.UserId)
    local session: Session = {
        encounter = Combat.new(Config, seedFor(player)), view = view,
        encounterId = 1, lastSnapshot = 0,
    }
    sessions[player] = session
    draw(session)
    print(string.format("[DinoGame] user=%d encounter=%d combatSeed=%d", player.UserId, session.encounterId, session.encounter.seed))
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player: Player)
    local session = sessions[player]
    if session then session.view.container:Destroy() end
    sessions[player] = nil
end)
for _, player in Players:GetPlayers() do addPlayer(player) end

command.OnServerEvent:Connect(function(player: Player, payload: any)
    local session = sessions[player]
    if not session then return end
    if not Combat.allowCommand(session.encounter, os.clock()) then return end
    if typeof(payload) ~= "table" then return end
    for key in payload do
        if key ~= "kind" and key ~= "value" and key ~= "encounterId" then return end
    end
    if typeof(payload.kind) ~= "string" or #payload.kind > 16 then return end
    if payload.value ~= nil and (typeof(payload.value) ~= "string" or #payload.value > 24) then return end
    if payload.kind == "Sync" then snapshot(player, session, nil); return end
    if payload.encounterId ~= session.encounterId then return end
    if payload.kind == "Restart" then
        if not session.encounter.outcome then snapshot(player, session, "Finish this encounter first"); return end
        local previous = session.encounter
        session.encounter = Combat.new(Config, seedFor(player))
        -- Restarts do not refresh the remote rate-limit budget.
        session.encounter.tokens = previous.tokens
        session.encounter.tokenTime = previous.tokenTime
        session.encounterId += 1
        draw(session)
        print(string.format("[DinoGame] user=%d encounter=%d combatSeed=%d", player.UserId, session.encounterId, session.encounter.seed))
        snapshot(player, session, nil)
        return
    end
    local accepted, reason = Combat.command(session.encounter, payload.kind, payload.value)
    snapshot(player, session, if accepted then nil else reason)
end)

local accumulator = 0
RunService.Heartbeat:Connect(function(dt: number)
    accumulator += math.min(dt, 0.25)
    while accumulator >= Config.Tick do
        accumulator -= Config.Tick
        for _, session in sessions do Combat.step(session.encounter, Config.Tick) end
    end
    for player, session in sessions do
        draw(session)
        if os.clock() - session.lastSnapshot >= Config.SnapshotInterval then
            session.lastSnapshot = os.clock()
            snapshot(player, session, nil)
        end
    end
end)
