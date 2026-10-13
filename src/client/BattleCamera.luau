--!strict
local Workspace = game:GetService("Workspace")
local CameraMath = require(script.Parent:WaitForChild("CameraMath"))

type Bounds = { frame: CFrame, size: Vector3 }
export type Rect = CameraMath.Rect
export type Controller = {
    zoom: number, yaw: number?, focus: Vector3?, position: Vector3?, distance: number?,
    reset: (self: Controller) -> (),
    adjustZoom: (self: Controller, amount: number) -> (),
    update: (self: Controller, camera: Camera, ally: Model, enemy: Model, rect: Rect, dt: number) -> (),
}

local BattleCamera = {}
local Settings = {
    FieldOfView = 55,
    ShoulderAngle = math.rad(52),
    Pitch = math.rad(12),
    TurnSpeed = 4,
    FocusSpeed = 9,
    ZoomInSpeed = 3,
    ZoomOutSpeed = 10,
    CollisionRadius = 0.65,
    Clearance = 0.25,
}

local function bounds(model: Model): Bounds
    local cf, size = model:GetBoundingBox()
    return { frame = cf, size = size }
end

local function corners(box: Bounds): { Vector3 }
    local result = {}
    for _, x in { -1, 1 } do
        for _, y in { -1, 1 } do
            for _, z in { -1, 1 } do
                table.insert(result, box.frame:PointToWorldSpace(box.size * Vector3.new(x, y, z) / 2))
            end
        end
    end
    return result
end

local function inside(position: Vector3, box: Bounds): boolean
    local p = box.frame:PointToObjectSpace(position)
    local half = box.size / 2 + Vector3.one * (Settings.CollisionRadius + Settings.Clearance)
    return math.abs(p.X) < half.X and math.abs(p.Y) < half.Y and math.abs(p.Z) < half.Z
end

local function basis(yaw: number, pitch: number): CFrame
    local forward = Vector3.new(math.sin(yaw), 0, math.cos(yaw))
    local side = Vector3.new(forward.Z, 0, -forward.X)
    local back = (-forward * math.cos(Settings.ShoulderAngle) + side * math.sin(Settings.ShoulderAngle)) * math.cos(pitch)
        + Vector3.yAxis * math.sin(pitch)
    return CFrame.lookAt(back, Vector3.zero).Rotation
end

local function solution(focus: Vector3, rotation: CFrame, points: { Vector3 }, rect: Rect, camera: Camera, zoom: number): (Vector3, number)
    local projected: { CameraMath.Point } = {}
    for _, point in points do
        local p = rotation:VectorToObjectSpace(point - focus)
        table.insert(projected, { x = p.X, y = p.Y, z = p.Z })
    end
    local tanV = math.tan(math.rad(Settings.FieldOfView / 2))
    local aspect = camera.ViewportSize.X / math.max(camera.ViewportSize.Y, 1)
    local distance = CameraMath.fit(projected, rect, tanV, aspect) * zoom
    local nx = (rect.left + rect.right) / 2
    local ny = (rect.top + rect.bottom) / 2
    local position = focus + rotation.ZVector * distance
        - rotation.RightVector * nx * distance * tanV * aspect
        + rotation.UpVector * ny * distance * tanV
    return position, distance
end

local function clear(focus: Vector3, position: Vector3, a: Bounds, b: Bounds, params: RaycastParams): boolean
    if inside(position, a) or inside(position, b) then return false end
    local direction = position - focus
    if direction.Magnitude < 1 then return false end
    return Workspace:Spherecast(focus, Settings.CollisionRadius, direction, params) == nil
end

local function safeEndpoint(position: Vector3, a: Bounds, b: Bounds, params: RaycastParams): boolean
    if inside(position, a) or inside(position, b) then return false end
    local overlap = OverlapParams.new()
    overlap.FilterType = params.FilterType
    overlap.FilterDescendantsInstances = params.FilterDescendantsInstances
    overlap.RespectCanCollide = true
    if #Workspace:GetPartBoundsInRadius(position, Settings.CollisionRadius, overlap) > 0 then return false end
    local terrain = RaycastParams.new()
    terrain.FilterType = Enum.RaycastFilterType.Include
    terrain.FilterDescendantsInstances = { Workspace.Terrain }
    local radius = Settings.CollisionRadius
    local ground = Workspace:Raycast(position + Vector3.yAxis * radius * 3, -Vector3.yAxis * radius * 4, terrain)
    return not ground or position.Y - ground.Position.Y >= radius
end

function BattleCamera.new(): Controller
    local self: Controller = {} :: any
    self.zoom = 1.06

    function self:reset()
        self.yaw, self.focus, self.position, self.distance = nil, nil, nil, nil
        self.zoom = 1.06
    end

    function self:adjustZoom(amount: number)
        -- Zooming in stops at the distance needed to keep both full bodies visible.
        self.zoom = math.clamp(self.zoom * math.exp(amount), 1, 1.8)
    end

    function self:update(camera: Camera, ally: Model, enemy: Model, rect: Rect, dt: number)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = Settings.FieldOfView
        local a, b = bounds(ally), bounds(enemy)
        local points = corners(a)
        for _, point in corners(b) do table.insert(points, point) end
        local targetFocus = a.frame.Position:Lerp(b.frame.Position, 0.45)
        local forward = ally:GetPivot().LookVector
        local targetYaw = math.atan2(forward.X, forward.Z)
        self.yaw = if self.yaw then CameraMath.angle(self.yaw, targetYaw, CameraMath.alpha(Settings.TurnSpeed, dt)) else targetYaw
        self.focus = if self.focus then self.focus:Lerp(targetFocus, CameraMath.alpha(Settings.FocusSpeed, dt)) else targetFocus
        local focus = self.focus :: Vector3
        local rotation = basis(self.yaw :: number, Settings.Pitch)
        local desired, distance = solution(focus, rotation, points, rect, camera, self.zoom)
        local speed = if self.distance and distance < self.distance then Settings.ZoomInSpeed else Settings.ZoomOutSpeed
        self.distance = if self.distance then self.distance + (distance - self.distance) * CameraMath.alpha(speed, dt) else distance
        -- Pulling back can never lag behind the full-body framing requirement.
        local minimum = select(2, solution(focus, rotation, points, rect, camera, 1))
        self.distance = math.max(self.distance :: number, minimum)
        desired = focus + (desired - focus) * (self.distance :: number) / distance

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { ally, enemy }
        params.RespectCanCollide = true
        if not clear(focus, desired, a, b, params) then
            -- Try another shoulder before raising the angle for an obstruction.
            for _, adjustment in { -math.rad(35), math.rad(35), -math.rad(80), math.rad(80), math.pi } do
                local alternative = basis((self.yaw :: number) + adjustment, math.rad(20))
                local candidate = solution(focus, alternative, points, rect, camera, self.zoom)
                if clear(focus, candidate, a, b, params) and safeEndpoint(candidate, a, b, params) then
                    desired, rotation = candidate, alternative
                    break
                end
            end
        end
        -- Focus, yaw and distance are already damped; a second position lerp would crop fast turns.
        local position = desired
        local hit = Workspace:Spherecast(focus, Settings.CollisionRadius, position - focus, params)
        if hit then
            position = focus + (position - focus).Unit * math.max(0.1, hit.Distance - Settings.Clearance)
        end
        if not safeEndpoint(position, a, b, params) then
            -- An obstruction can make a full-body shot impossible. Prefer physical clearance.
            if self.position and safeEndpoint(self.position, a, b, params) then
                position = self.position
            elseif safeEndpoint(desired, a, b, params) then
                position = desired
            else
                for step = 1, 12 do
                    local alternative = basis((self.yaw :: number) + step * math.pi / 6, math.rad(30))
                    local candidate = solution(focus, alternative, points, rect, camera, self.zoom)
                    if safeEndpoint(candidate, a, b, params) then
                        position, rotation = candidate, alternative
                        break
                    end
                end
            end
        end
        if not safeEndpoint(position, a, b, params) then
            -- Keep the previous valid render if no shot exists in a fully enclosed space.
            return
        end
        self.position = position
        camera.CFrame = CFrame.new(position) * rotation
        camera.Focus = CFrame.new(targetFocus)
    end

    return self
end

return BattleCamera
