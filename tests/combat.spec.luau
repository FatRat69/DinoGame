--!strict
local Combat = require("../src/shared/Combat")
local Config = require("../src/shared/Config")
local passed = 0

local function test(name: string, run: () -> ())
    run()
    passed += 1
    print("PASS " .. name)
end

local function close(e: Combat.Encounter)
    e.ally.x, e.ally.z, e.ally.yaw = -2.5, 0, math.pi / 2
    e.enemy.x, e.enemy.z, e.enemy.yaw = 2.5, 0, -math.pi / 2
    e.nextAiThink, e.nextAiAttack = math.huge, math.huge
    e.enemy.stance = "Neutral"
end

local function advance(e: Combat.Encounter, seconds: number)
    for _ = 1, math.ceil(seconds / Config.Tick) do Combat.step(e, Config.Tick) end
end

test("reject unknown commands and stances", function()
    local e = Combat.new(Config, 42)
    assert(not Combat.command(e, "Damage", "9999"))
    assert(not Combat.command(e, "Attack", "Forged"))
    assert(not Combat.command(e, "Stance", "Teleport"))
    assert(e.ally.hp == Config.Species.deinonychus.maxHp)
end)

test("range, legal stance, stamina and committed action gates", function()
    local e = Combat.new(Config, 42)
    assert(not Combat.command(e, "Attack", "Bite"))
    close(e)
    assert(Combat.command(e, "Stance", "Defensive"))
    assert(not Combat.command(e, "Attack", "Bite"))
    assert(Combat.command(e, "Stance", "Offensive"))
    e.ally.stamina = 0
    assert(not Combat.command(e, "Attack", "Swipe"))
    e.ally.stamina = 100
    assert(Combat.command(e, "Attack", "Bite"))
    assert(e.ally.stamina == 82)
    assert(not Combat.command(e, "Attack", "Swipe"))
    assert(not Combat.command(e, "Rest", nil))
    assert(not Combat.command(e, "Stance", "Defensive"))
    assert(e.ally.stamina == 82)
end)

test("single damage resolution, windup, recovery and cooldown", function()
    local e = Combat.new(Config, 42)
    close(e)
    e.enemy.phase, e.enemy.phaseUntil = "Recovery", 10
    assert(Combat.command(e, "Attack", "Bite"))
    advance(e, 0.3)
    assert(e.enemy.hp == 110 and e.ally.phase == "Windup")
    advance(e, 0.2)
    assert(e.enemy.hp == 92)
    advance(e, 0.65)
    assert(e.enemy.hp == 92 and e.ally.phase == "Idle")
    local ok, reason = Combat.canAttack(e, e.ally, e.enemy, "Bite")
    assert(not ok and reason == "Cooldown")
end)

test("range rechecked on strike; moving target causes miss", function()
    local e = Combat.new(Config, 42)
    close(e)
    assert(Combat.command(e, "Attack", "Bite"))
    e.enemy.x = 20
    e.enemy.phase, e.enemy.phaseUntil = "Recovery", 10
    advance(e, 0.5)
    assert(e.enemy.hp == 110)
    assert(e.events[#e.events].kind == "Miss")
end)

test("facing rechecked on strike", function()
    local e = Combat.new(Config, 42)
    close(e)
    e.enemy.phase, e.enemy.phaseUntil = "Recovery", 10
    e.ally.yaw = -math.pi / 2
    assert(Combat.command(e, "Attack", "Bite"))
    advance(e, 0.5)
    assert(e.enemy.hp == 110 and e.events[#e.events].kind == "Miss")
end)

test("seeded accuracy can miss an in-range attack", function()
    local e = Combat.new(Config, 44000)
    close(e)
    e.enemy.phase, e.enemy.phaseUntil = "Recovery", 10
    assert(Combat.command(e, "Attack", "Bite"))
    advance(e, 0.5)
    assert(e.enemy.hp == 110 and e.events[#e.events].kind == "Miss")
end)

test("manual Rest recovers stamina, freezes movement and increases incoming damage", function()
    local e = Combat.new(Config, 42)
    close(e)
    e.ally.stamina = 20
    assert(Combat.command(e, "Rest", nil))
    local x = e.ally.x
    assert(Combat.attack(e, e.enemy, e.ally, "Bite"))
    advance(e, 0.5)
    assert(e.ally.hp == 104) -- round(18 * 0.85 * 1.4)
    assert(e.ally.stamina >= 32 and e.ally.x == x)
    advance(e, 2)
    assert(e.ally.phase == "Idle" and e.ally.stamina <= 100)
end)

test("rate limit bursts, refill and backwards clocks", function()
    local e = Combat.new(Config, 42)
    for _ = 1, Config.MaxCommandBurst do assert(Combat.allowCommand(e, 10)) end
    assert(not Combat.allowCommand(e, 10))
    assert(not Combat.allowCommand(e, 9))
    assert(Combat.allowCommand(e, 10.125))
    assert(not Combat.allowCommand(e, 10.125))
end)

test("four stances produce distinct movement without steering input", function()
    for _, stance in Config.Stances do
        local e = Combat.new(Config, 42)
        e.enemy.phase, e.enemy.phaseUntil = "Recovery", 10
        e.ally.x, e.enemy.x = -4, 4
        assert(Combat.command(e, "Stance", stance))
        Combat.step(e, Config.Tick)
        if stance == "Offensive" or stance == "Neutral" then assert(e.ally.x > -4)
        elseif stance == "Defensive" then assert(e.ally.x < -4)
        else assert(math.abs(e.ally.z) > 0) end
    end
end)

test("lethal strike finishes encounter and rejects all subsequent actions", function()
    local e = Combat.new(Config, 42)
    close(e)
    e.enemy.phase, e.enemy.phaseUntil = "Recovery", 10
    e.enemy.hp = 1
    assert(Combat.command(e, "Attack", "Bite"))
    advance(e, 1)
    assert(e.outcome == "Victory" and e.enemy.hp == 0)
    assert(not Combat.command(e, "Attack", "Bite"))
    assert(not Combat.command(e, "Stance", "Neutral"))
    assert(not Combat.command(e, "Rest", nil))
    local time = e.time
    Combat.step(e, 1)
    assert(e.time == time)
    local restart = Combat.new(Config, 42)
    assert(not restart.outcome and restart.ally.stamina == 100 and restart.enemy.hp == 110)
    assert(#restart.events == 0 and next(restart.ally.cooldowns) == nil)
end)

local function simulate(seed: number): Combat.Encounter
    local e = Combat.new(Config, seed)
    for _ = 1, 30 * 180 do
        if e.outcome then break end
        if e.ally.phase == "Idle" then
            if e.ally.stamina < 22 then
                Combat.rest(e, e.ally)
            else
                local canBite = Combat.canAttack(e, e.ally, e.enemy, "Bite")
                if canBite then Combat.command(e, "Attack", "Bite")
                else Combat.command(e, "Attack", "Swipe") end
            end
        end
        Combat.step(e, Config.Tick)
        for _, f in { e.ally, e.enemy } do
            assert(f.hp >= 0 and f.stamina >= 0 and f.stamina <= f.species.maxStamina)
            assert(math.abs(f.x) <= Config.ArenaHalfSize and math.abs(f.z) <= Config.ArenaHalfSize)
        end
    end
    assert(e.outcome, "AI stalled for seed " .. tostring(seed))
    return e
end

test("same seed and commands reproduce combat and event sequence", function()
    local a, b = simulate(1234), simulate(1234)
    assert(a.time == b.time and a.rng == b.rng and a.outcome == b.outcome)
    assert(a.ally.hp == b.ally.hp and a.enemy.hp == b.enemy.hp)
    assert(a.sequence == b.sequence)
    for index, event in a.events do assert(event.text == b.events[index].text) end
end)

test("20 seeded complete battles preserve bounds and stamina limits", function()
    local wins, losses = 0, 0
    for seed = 1, 20 do
        local e = simulate(seed * 997)
        if e.outcome == "Victory" then wins += 1 else losses += 1 end
    end
    print(string.format("Automated battles: %d wins, %d losses (not human Studio playtests)", wins, losses))
end)

test("idle player can lose to autonomous enemy AI", function()
    local e = Combat.new(Config, 100)
    advance(e, 180)
    assert(e.outcome == "Defeat")
end)

print(string.format("%d rule tests passed", passed))
