--!strict
-- Original provisional tuning for the two-species prototype only.
type Skill = {
    id: string, name: string, damage: number, effort: number, accuracy: number,
    range: number, windup: number, strike: number, recovery: number, cooldown: number,
    coneDot: number, stances: { [string]: boolean },
}
type Species = {
    id: string, name: string, maxHp: number, maxStamina: number,
    speed: number, turnSpeed: number, damageScale: number,
}
return {
    Tick = 1 / 30,
    SnapshotInterval = 1 / 10,
    ArenaHalfSize = 27,
    MinimumSpacing = 3.0,
    MaxCommandsPerSecond = 8,
    MaxCommandBurst = 10,
    RestDuration = 2.4,
    RestRecovery = 24,
    RestDamageMultiplier = 1.4,
    PassiveRecovery = 3,
    Stances = { "Offensive", "Neutral", "Defensive", "Flanking" },
    Skills = {
        Bite = {
            id = "Bite", name = "Bite", damage = 18, effort = 18, accuracy = 0.86,
            range = 6.8, windup = 0.45, strike = 0.12, recovery = 0.55, cooldown = 1.8,
            coneDot = 0.15,
            stances = { Offensive = true, Neutral = true, Flanking = true } :: { [string]: boolean },
        },
        Swipe = {
            id = "Swipe", name = "Swipe", damage = 11, effort = 12, accuracy = 0.93,
            range = 7.2, windup = 0.28, strike = 0.12, recovery = 0.38, cooldown = 1.2,
            coneDot = -0.2,
            stances = { Offensive = true, Neutral = true, Defensive = true, Flanking = true } :: { [string]: boolean },
        },
    } :: { [string]: Skill },
    Species = {
        deinonychus = {
            id = "deinonychus", name = "Deinonychus", maxHp = 125, maxStamina = 100,
            speed = 9, turnSpeed = 5.5, damageScale = 1,
        },
        gallimimus = {
            id = "gallimimus", name = "Gallimimus", maxHp = 110, maxStamina = 100,
            speed = 10.5, turnSpeed = 5, damageScale = 0.85,
        },
    } :: { [string]: Species },
}
