--!strict
local Math = require("../src/client/CameraMath")
local passed = 0
local function test(name: string, callback: () -> ())
    callback()
    passed += 1
    print("PASS " .. name)
end

local function box(points: { Math.Point }, x: number, z: number, size: number)
    for _, sx in { -1, 1 } do
        for _, sy in { -1, 1 } do
            for _, sz in { -1, 1 } do
                table.insert(points, { x = x + sx * size, y = sy * size * 0.7, z = z + sz * size * 1.5 })
            end
        end
    end
end

local rects: { Math.Rect } = {
    { left = -0.95, right = 0.95, top = -0.45, bottom = 0.3 },
    { left = -0.86, right = 0.86, top = -0.35, bottom = 0.18 },
    { left = -0.9, right = 0.15, top = -0.05, bottom = 0.85 },
}

test("both full bodies fit HUD-safe rectangle across separation, aspect and size", function()
    local count = 0
    for _, aspect in { 0.45, 0.7, 1.1, 1.8, 2.4 } do
        for _, rect in rects do
            for _, separation in { 3, 10, 35, 70 } do
                for _, size in { 1, 4, 15 } do
                    local points: { Math.Point } = {}
                    box(points, -separation / 2, -separation / 3, 2)
                    box(points, separation / 2, separation / 3, size)
                    local tanV = math.tan(math.rad(55 / 2))
                    local distance = Math.fit(points, rect, tanV, aspect)
                    local nx, ny = (rect.left + rect.right) / 2, (rect.top + rect.bottom) / 2
                    for _, point in points do
                        local depth = distance - point.z
                        assert(depth >= 0.999999)
                        local x = (point.x / (tanV * aspect) + nx * distance) / depth
                        local y = (-point.y / tanV + ny * distance) / depth
                        assert(x >= rect.left - 0.000001 and x <= rect.right + 0.000001)
                        assert(y >= rect.top - 0.000001 and y <= rect.bottom + 0.000001)
                    end
                    count += 1
                end
            end
        end
    end
    print(string.format("Framing scenarios checked: %d", count))
end)

test("distance expands with separation and larger model bounds", function()
    local close: { Math.Point } = {}
    box(close, -2, 0, 2); box(close, 2, 0, 2)
    local far: { Math.Point } = {}
    box(far, -18, -10, 2); box(far, 18, 10, 2)
    local giant: { Math.Point } = {}
    box(giant, -2, 0, 2); box(giant, 2, 0, 15)
    local nearDistance = Math.fit(close, rects[1], 0.5, 1.5)
    assert(Math.fit(far, rects[1], 0.5, 1.5) > nearDistance)
    assert(Math.fit(giant, rects[1], 0.5, 1.5) > nearDistance)
end)

test("damping is consistent at 30 and 120 frames per second", function()
    local a, b = 0, 0
    for _ = 1, 30 do a += (1 - a) * Math.alpha(4, 1 / 30) end
    for _ = 1, 120 do b += (1 - b) * Math.alpha(4, 1 / 120) end
    assert(math.abs(a - b) < 0.000001)
    assert(Math.alpha(4, 0) == 0 and Math.alpha(4, -1) == 0)
end)

test("yaw follows shortest path across angle wrap", function()
    local start, finish = math.rad(179), math.rad(-179)
    local midpoint = Math.angle(start, finish, 0.5)
    assert(math.abs(midpoint - math.pi) < 0.000001)
end)

print(string.format("%d camera tests passed", passed))
