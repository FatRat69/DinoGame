--!strict
local Arena = {}

export type ArenaView = { container: Model, ally: Model, enemy: Model, center: Vector3 }

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.Position = position
    item.Color = color
    item.Material = Enum.Material.SmoothPlastic
    item.Anchored = true
    item.CanCollide = false
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Parent = parent
    return item
end

local function dinosaur(parent: Instance, name: string, role: string, color: Color3, tall: boolean): Model
    local model = Instance.new("Model")
    model.Name = name
    local body = part(model, "Body", Vector3.new(2.3, 2, 4), Vector3.new(0, 3.1, 0), color)
    model.PrimaryPart = body
    part(model, "Neck", Vector3.new(1.2, if tall then 3.0 else 1.4, 1.2), Vector3.new(0, if tall then 4.5 else 3.9, -2), color)
    part(model, "Head", Vector3.new(1.5, 1.2, 2), Vector3.new(0, if tall then 6 else 4.5, -2.8), color)
    part(model, "Tail", Vector3.new(0.8, 0.8, 4.5), Vector3.new(0, 3.2, 3.8), color)
    for _, side in { -1, 1 } do
        part(model, "Leg", Vector3.new(0.7, 2.3, 0.8), Vector3.new(side * 1.1, 1.65, 0.5), color:Lerp(Color3.new(0, 0, 0), 0.15))
        part(model, "Foot", Vector3.new(0.9, 0.5, 1.8), Vector3.new(side * 1.1, 0.4, -0.1), color)
        part(model, "Arm", Vector3.new(0.5, 0.5, 1.9), Vector3.new(side * 1.3, 3.5, -1.6), color)
        part(model, "Eye", Vector3.new(0.1, 0.25, 0.3), Vector3.new(side * 0.77, if tall then 6.2 else 4.7, -3.2), Color3.fromRGB(23, 28, 28))
    end
    model:SetAttribute("CombatRole", role)
    model:PivotTo(CFrame.new(0, 0, 0))
    model.Parent = parent
    return model
end

function Arena.create(parent: Instance, center: Vector3, name: string): ArenaView
    local container = Instance.new("Model")
    container.Name = name
    local floor = part(container, "ArenaFloor", Vector3.new(62, 1, 62), center - Vector3.new(0, 0.5, 0), Color3.fromRGB(76, 116, 86))
    floor.Material = Enum.Material.Grass
    floor.CanCollide = true
    for _, side in { -1, 1 } do
        part(container, "Boundary", Vector3.new(62, 0.2, 0.5), center + Vector3.new(0, 0.1, side * 30), Color3.fromRGB(224, 233, 220))
        part(container, "Boundary", Vector3.new(0.5, 0.2, 62), center + Vector3.new(side * 30, 0.1, 0), Color3.fromRGB(224, 233, 220))
    end
    local ally = dinosaur(container, "Deinonychus", "ally", Color3.fromRGB(51, 179, 155), false)
    local enemy = dinosaur(container, "Gallimimus", "enemy", Color3.fromRGB(202, 99, 108), true)
    container.Parent = parent
    return { container = container, ally = ally, enemy = enemy, center = center }
end

function Arena.update(model: Model, center: Vector3, x: number, z: number, yaw: number, phase: string, hp: number)
    local position = center + Vector3.new(x, 3.1, z)
    local direction = Vector3.new(math.sin(yaw), 0, math.cos(yaw))
    local lean = if phase == "Windup" then -0.14 elseif phase == "Strike" then 0.2 elseif phase == "Rest" then 0.12 else 0
    model:PivotTo(CFrame.lookAt(position, position + direction) * CFrame.Angles(lean, 0, 0))
    local body = model.PrimaryPart
    if body then
        body.Material = if phase == "Windup" or phase == "Strike" then Enum.Material.Neon else Enum.Material.SmoothPlastic
        body.Transparency = if hp <= 0 then 0.6 else 0
    end
end

return Arena
