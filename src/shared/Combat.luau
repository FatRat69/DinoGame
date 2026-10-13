--!strict
-- Pure server simulation: seconds, studs and scalar coordinates, with no Roblox services.
export type Stance = "Offensive" | "Neutral" | "Defensive" | "Flanking"
export type Phase = "Idle" | "Windup" | "Strike" | "Recovery" | "Rest"
export type Species = {
    id: string, name: string, maxHp: number, maxStamina: number,
    speed: number, turnSpeed: number, damageScale: number,
}
export type Skill = {
    id: string, name: string, damage: number, effort: number, accuracy: number,
    range: number, windup: number, strike: number, recovery: number, cooldown: number,
    coneDot: number, stances: { [string]: boolean },
}
export type Config = {
    Tick: number, SnapshotInterval: number, ArenaHalfSize: number, MinimumSpacing: number,
    MaxCommandsPerSecond: number, MaxCommandBurst: number,
    RestDuration: number, RestRecovery: number, RestDamageMultiplier: number,
    PassiveRecovery: number, Stances: { string }, Skills: { [string]: Skill },
    Species: { [string]: Species },
}
export type Fighter = {
    id: string, species: Species, hp: number, stamina: number,
    x: number, z: number, yaw: number, stance: Stance, phase: Phase,
    phaseUntil: number, skill: string?, cooldowns: { [string]: number },
}
export type Event = { sequence: number, time: number, actor: string, text: string, kind: string }
export type Encounter = {
    config: Config, seed: number, rng: number, time: number,
    ally: Fighter, enemy: Fighter, outcome: string?, events: { Event }, sequence: number,
    nextAiThink: number, nextAiAttack: number, tokens: number, tokenTime: number,
}

local Combat = {}

local function fighter(id: string, species: Species, x: number, yaw: number): Fighter
    return {
        id = id, species = species, hp = species.maxHp, stamina = species.maxStamina,
        x = x, z = 0, yaw = yaw, stance = "Offensive", phase = "Idle",
        phaseUntil = 0, skill = nil, cooldowns = {},
    }
end

function Combat.new(config: Config, seed: number): Encounter
    local normalized = math.floor(seed) % 2147483647
    if normalized <= 0 then normalized = 1 end
    return {
        config = config, seed = normalized, rng = normalized, time = 0,
        ally = fighter("ally", config.Species.deinonychus, -10, math.pi / 2),
        enemy = fighter("enemy", config.Species.gallimimus, 10, -math.pi / 2),
        outcome = nil, events = {}, sequence = 0,
        nextAiThink = 0.6, nextAiAttack = 1.6,
        tokens = config.MaxCommandBurst, tokenTime = 0,
    }
end

function Combat.distance(a: Fighter, b: Fighter): number
    return math.sqrt((a.x - b.x) ^ 2 + (a.z - b.z) ^ 2)
end

function Combat.random(encounter: Encounter): number
    encounter.rng = (encounter.rng * 48271) % 2147483647
    return encounter.rng / 2147483647
end

local function emit(e: Encounter, f: Fighter, kind: string, message: string)
    e.sequence += 1
    table.insert(e.events, {
        sequence = e.sequence, time = e.time, actor = f.id,
        kind = kind, text = message,
    })
    if #e.events > 12 then table.remove(e.events, 1) end
end

function Combat.canAttack(e: Encounter, f: Fighter, target: Fighter, skillId: string): (boolean, string)
    local move = e.config.Skills[skillId]
    if e.outcome or f.hp <= 0 or target.hp <= 0 then return false, "Encounter finished" end
    if not move then return false, "Unknown attack" end
    if f.phase ~= "Idle" then return false, f.phase end
    if not move.stances[f.stance] then return false, "Illegal stance" end
    if (f.cooldowns[skillId] or 0) > e.time then return false, "Cooldown" end
    if f.stamina < move.effort then return false, "Low stamina" end
    if Combat.distance(f, target) > move.range then return false, "Out of range" end
    return true, "Ready"
end

function Combat.attack(e: Encounter, f: Fighter, target: Fighter, skillId: string): (boolean, string)
    local ok, reason = Combat.canAttack(e, f, target, skillId)
    if not ok then return false, reason end
    local move = e.config.Skills[skillId]
    f.stamina -= move.effort
    f.cooldowns[skillId] = e.time + move.cooldown
    f.skill = skillId
    f.phase = "Windup"
    f.phaseUntil = e.time + move.windup
    emit(e, f, "Windup", f.species.name .. " prepares " .. move.name)
    return true, "Accepted"
end

function Combat.rest(e: Encounter, f: Fighter): (boolean, string)
    if e.outcome or f.hp <= 0 then return false, "Encounter finished" end
    if f.phase ~= "Idle" then return false, f.phase end
    if f.stamina >= f.species.maxStamina then return false, "Stamina full" end
    f.phase = "Rest"
    f.skill = nil
    f.phaseUntil = e.time + e.config.RestDuration
    emit(e, f, "Rest", f.species.name .. " rests")
    return true, "Accepted"
end

function Combat.setStance(e: Encounter, f: Fighter, value: string): (boolean, string)
    if e.outcome then return false, "Encounter finished" end
    if f.phase ~= "Idle" then return false, f.phase end
    if value ~= "Offensive" and value ~= "Neutral" and value ~= "Defensive" and value ~= "Flanking" then
        return false, "Unknown stance"
    end
    f.stance = value :: Stance
    return true, "Accepted"
end

function Combat.allowCommand(e: Encounter, now: number): boolean
    e.tokens = math.min(e.config.MaxCommandBurst, e.tokens + math.max(0, now - e.tokenTime) * e.config.MaxCommandsPerSecond)
    e.tokenTime = math.max(now, e.tokenTime)
    if e.tokens < 1 then return false end
    e.tokens -= 1
    return true
end

function Combat.command(e: Encounter, kind: string, value: string?): (boolean, string)
    if kind == "Stance" and value then return Combat.setStance(e, e.ally, value) end
    if kind == "Attack" and value then return Combat.attack(e, e.ally, e.enemy, value) end
    if kind == "Rest" then return Combat.rest(e, e.ally) end
    return false, "Unknown command"
end

local function turnToward(f: Fighter, dx: number, dz: number, dt: number)
    if dx * dx + dz * dz < 0.0001 then return end
    local desired = math.atan2(dx, dz)
    local angle = (desired - f.yaw + math.pi) % (2 * math.pi) - math.pi
    f.yaw += math.clamp(angle, -f.species.turnSpeed * dt, f.species.turnSpeed * dt)
end

local function movement(e: Encounter, f: Fighter, target: Fighter, dt: number)
    if f.phase ~= "Idle" then return end
    local dx, dz = target.x - f.x, target.z - f.z
    local distance = math.sqrt(dx * dx + dz * dz)
    if distance < 0.001 then return end
    local ux, uz = dx / distance, dz / distance
    local vx, vz = 0, 0
    if f.stance == "Offensive" then
        if distance > 4.6 then vx, vz = ux, uz end
    elseif f.stance == "Neutral" then
        if distance > 6.3 then vx, vz = ux, uz
        elseif distance < 5.6 then vx, vz = -ux, -uz end
    elseif f.stance == "Defensive" then
        if distance < 13 then vx, vz = -ux, -uz end
    else
        -- Seek the enemy's rear quarter, with bounded tangential movement nearby.
        local tx = target.x - math.sin(target.yaw) * 5.2 + math.cos(target.yaw) * 2.5
        local tz = target.z - math.cos(target.yaw) * 5.2 - math.sin(target.yaw) * 2.5
        local fx, fz = tx - f.x, tz - f.z
        local length = math.sqrt(fx * fx + fz * fz)
        if length > 0.5 then vx, vz = fx / length, fz / length end
    end
    local speed = f.species.speed * (if f.stamina < 10 then 0.7 else 1)
    f.x = math.clamp(f.x + vx * speed * dt, -e.config.ArenaHalfSize, e.config.ArenaHalfSize)
    f.z = math.clamp(f.z + vz * speed * dt, -e.config.ArenaHalfSize, e.config.ArenaHalfSize)
    turnToward(f, target.x - f.x, target.z - f.z, dt)
end

local function resolveHit(e: Encounter, f: Fighter, target: Fighter, move: Skill)
    local distance = Combat.distance(f, target)
    local facing = 1
    if distance > 0.001 then
        facing = (math.sin(f.yaw) * (target.x - f.x) + math.cos(f.yaw) * (target.z - f.z)) / distance
    end
    local accuracy = move.accuracy * (if target.stance == "Defensive" and target.phase == "Idle" then 0.78 else 1)
    local roll = Combat.random(e)
    if distance > move.range or facing < move.coneDot or roll > accuracy then
        emit(e, f, "Miss", f.species.name .. " missed " .. move.name)
        return
    end
    local damage = move.damage * f.species.damageScale
    if target.phase == "Rest" then damage *= e.config.RestDamageMultiplier end
    damage = math.floor(damage + 0.5)
    target.hp = math.max(0, target.hp - damage)
    emit(e, f, "Hit", f.species.name .. " landed " .. move.name .. " for " .. tostring(damage))
end

local function phase(e: Encounter, f: Fighter, target: Fighter, dt: number)
    if f.phase == "Rest" then
        f.stamina = math.min(f.species.maxStamina, f.stamina + e.config.RestRecovery * dt)
    elseif f.phase == "Idle" then
        f.stamina = math.min(f.species.maxStamina, f.stamina + e.config.PassiveRecovery * dt)
    end
    if f.phase == "Idle" or e.time + 0.000001 < f.phaseUntil then return end
    if f.phase == "Rest" or f.phase == "Recovery" then
        f.phase = "Idle"
        f.skill = nil
        return
    end
    local move = e.config.Skills[f.skill :: string]
    if f.phase == "Windup" then
        f.phase = "Strike"
        f.phaseUntil = e.time + move.strike
        resolveHit(e, f, target, move)
    else
        f.phase = "Recovery"
        f.phaseUntil = e.time + move.recovery
    end
end

local function ai(e: Encounter)
    local f, target = e.enemy, e.ally
    if f.phase ~= "Idle" then return end
    if f.stamina < 25 then
        f.stance = "Defensive"
        if Combat.distance(f, target) > 10 or f.stamina < 12 then Combat.rest(e, f) end
        return
    end
    if e.time >= e.nextAiThink then
        e.nextAiThink = e.time + 1.6
        local roll = Combat.random(e)
        f.stance = if roll < 0.58 then "Offensive" elseif roll < 0.86 then "Flanking" else "Neutral"
    end
    if e.time >= e.nextAiAttack then
        local skillId = if Combat.random(e) < 0.6 then "Swipe" else "Bite"
        local accepted = Combat.attack(e, f, target, skillId)
        e.nextAiAttack = e.time + (if accepted then 1.0 else 0.3)
    end
end

function Combat.step(e: Encounter, dt: number)
    if e.outcome then return end
    e.time += dt
    ai(e)
    movement(e, e.ally, e.enemy, dt)
    movement(e, e.enemy, e.ally, dt)
    local distance = Combat.distance(e.ally, e.enemy)
    if distance < e.config.MinimumSpacing then
        local dx, dz = e.enemy.x - e.ally.x, e.enemy.z - e.ally.z
        if distance < 0.001 then dx, dz, distance = 1, 0, 1 end
        local correction = (e.config.MinimumSpacing - distance) / 2
        local ux, uz = dx / distance, dz / distance
        local limit = e.config.ArenaHalfSize
        e.ally.x = math.clamp(e.ally.x - ux * correction, -limit, limit)
        e.ally.z = math.clamp(e.ally.z - uz * correction, -limit, limit)
        e.enemy.x = math.clamp(e.enemy.x + ux * correction, -limit, limit)
        e.enemy.z = math.clamp(e.enemy.z + uz * correction, -limit, limit)
    end
    phase(e, e.ally, e.enemy, dt)
    if e.enemy.hp > 0 then phase(e, e.enemy, e.ally, dt) end
    if e.ally.hp <= 0 or e.enemy.hp <= 0 then
        local outcome = if e.ally.hp > 0 then "Victory" else "Defeat"
        e.outcome = outcome
        emit(e, e.ally, "Outcome", outcome)
    end
end

return Combat
