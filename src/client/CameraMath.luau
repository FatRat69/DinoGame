--!strict
-- Projection math is independent of Roblox so framing can be regression-tested.
export type Point = { x: number, y: number, z: number }
export type Rect = { left: number, right: number, top: number, bottom: number }

local CameraMath = {}

function CameraMath.alpha(speed: number, dt: number): number
    return 1 - math.exp(-speed * math.max(0, dt))
end

function CameraMath.angle(current: number, target: number, amount: number): number
    local delta = (target - current + math.pi) % (2 * math.pi) - math.pi
    return current + delta * amount
end

function CameraMath.fit(points: { Point }, rect: Rect, tanVertical: number, aspect: number): number
    local nx = (rect.left + rect.right) / 2
    local ny = (rect.top + rect.bottom) / 2
    local tanHorizontal = tanVertical * aspect
    local distance = 1
    for _, p in points do
        distance = math.max(distance, p.z + 1,
            (-p.x / tanHorizontal - rect.left * p.z) / (nx - rect.left),
            (p.x / tanHorizontal + rect.right * p.z) / (rect.right - nx),
            (p.y / tanVertical - rect.top * p.z) / (ny - rect.top),
            (-p.y / tanVertical + rect.bottom * p.z) / (rect.bottom - ny))
    end
    return distance
end

return CameraMath
