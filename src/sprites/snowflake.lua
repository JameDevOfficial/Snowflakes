local M = {}
M.__index = M
M.lastSpawned = 0

function M:new(opts)
    opts = opts or {}
    local o = setmetatable({}, self)
    o.type = "snowflake"
    o.radius = opts.radius or Core.screen.minSize
    o.maxOffset = opts.maxOffset or 35
    print(o.maxOffset)
    o.color = opts.color or { 1, 1, 1, 1 }
    o.position = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.speed = opts.speed or math.random(50, 150)
    o.points = opts.points or M:createRandomShape(o.radius, o.maxOffset, 0, 0)
    o.angle = opts.angle or 0

    local canvasSize = (o.radius + o.maxOffset) * 2
    o.canvas = love.graphics.newCanvas(canvasSize, canvasSize)
    love.graphics.setCanvas(o.canvas)
    love.graphics.clear()
    love.graphics.push()
    love.graphics.translate(canvasSize / 2, canvasSize / 2)
    love.graphics.setColor(o.color)
    love.graphics.setLineWidth(2)
    if Core.isMobile then
        love.graphics.setLineWidth(1)
    end
    love.graphics.line(o.points)
    love.graphics.pop()
    love.graphics.setCanvas()

    return o
end

function M:shiftPointsToOrigin(points, position, radius)
    local shifted = {}
    for i = 1, #points, 2 do
        table.insert(shifted, points[i] - position.x + radius)
        table.insert(shifted, points[i + 1] - position.y + radius)
    end
    return shifted
end

function M:update(dt)
    if Core.status == INMENU then
        self.position.y = self.position.y + self.speed * dt * 0.5
        self.angle = (self.angle + dt * self.speed / 300) % (2 * math.pi)
    end
end

function M:render()
    if Core.status == INGAME or Core.status == INMENU then
        love.graphics.push()
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.rotate(self.angle)
        love.graphics.setColor(1, 1, 1, 1)
        local canvasSize = (self.radius + self.maxOffset) * 2
        love.graphics.draw(self.canvas, -canvasSize / 2, -canvasSize / 2)
        if Settings.DEBUG then
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", -canvasSize / 2, -canvasSize / 2, canvasSize, canvasSize)
        end

        love.graphics.pop()
    end
end

function M:createRandomShape(radius, maxOffset, cx, cy)
    local branches, pointsPerBranch, pointsPerBranchSide
    if Core.status == INMENU then
        branches = 5 + math.random(1, 4)
        pointsPerBranch = 8 + 2 * math.random(1, 4)
    else
        branches = 5 + math.random(1, 6)
        pointsPerBranch = 32 + 2 * math.random(1, 6)
    end

    local pointsPerBranchSide = pointsPerBranch / 2
    local lastPoint = nil
    print("Branches: " .. branches .. "\nPoints Per Branch: " .. pointsPerBranch)

    --Half branch
    local halfBranch = {}
    local lastOffset = 0
    for i = 1, pointsPerBranchSide do
        local t = i / pointsPerBranchSide
        local r = radius * t
        local lateralOffset = math.random(0, maxOffset) * 1.7 * r / radius
        if lastOffset >= 3 * maxOffset / 5 then
            t = (i - 0.5) / pointsPerBranch
            r = radius * t
            lateralOffset = 0
        end
        lastOffset = lateralOffset
        local x, y
        if i == pointsPerBranchSide then
            x = math.cos(0) * r + math.sin(0) * lateralOffset
            y = math.sin(0) * r - math.cos(0)
        elseif i == 1 then
            x = math.sin(0) * r - math.cos(0)
            y = math.sin(0) * r - math.cos(0) * lateralOffset
        else
            x = math.cos(0) * r + math.sin(0) * lateralOffset
            y = math.sin(0) * r - math.cos(0) * lateralOffset
        end
        table.insert(halfBranch, x)
        table.insert(halfBranch, y)
    end

    -- Mirror
    local fullBranch = {}
    for i = 1, #halfBranch, 2 do
        table.insert(fullBranch, halfBranch[i])
        table.insert(fullBranch, halfBranch[i + 1])
    end
    for i = #halfBranch, 1, -2 do
        local x = halfBranch[i - 1]
        local y = halfBranch[i]
        table.insert(fullBranch, x)
        table.insert(fullBranch, -y)
    end

    local vertices = {}
    table.insert(vertices, cx)
    table.insert(vertices, cy)
    for b = 1, branches do
        local angle = (2 * math.pi / branches) * (b - 1)
        for i = 1, #fullBranch, 2 do
            local x = cx + math.cos(angle) * fullBranch[i] - math.sin(angle) * fullBranch[i + 1]
            local y = cy + math.sin(angle) * fullBranch[i] + math.cos(angle) * fullBranch[i + 1]
            if lastPoint == nil then lastPoint = { x, y } end
            table.insert(vertices, x)
            table.insert(vertices, y)
        end
    end
    table.insert(vertices, lastPoint[1])
    table.insert(vertices, lastPoint[2])

    return vertices
end

function M:movePoints(opts, o)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for i = 1, #opts.points, 2 do
        local x, y = opts.points[i], opts.points[i + 1]
        if x < minX then minX = x end
        if y < minY then minY = y end
        if x > maxX then maxX = x end
        if y > maxY then maxY = y end
    end
    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2
    o.points = {}
    for i = 1, #opts.points, 2 do
        local x, y = opts.points[i], opts.points[i + 1]
        local dx = x - centerX + o.position.x
        local dy = y - centerY + o.position.y
        table.insert(o.points, dx)
        table.insert(o.points, dy)
    end
end

function M.spawnRandomSnowflakesBackground(dt)
    M.lastSpawned = M.lastSpawned + dt
    if M.lastSpawned > Settings.snowflake.spawnDelay and math.random(1, 100) < Settings.snowflake.spawnChance then
        local rad = math.random(25, 100)
        local sat = math.random(40, 80) / 100
        local hue = math.random(70, 90) / 100
        local opts = {
            radius = rad,
            position = {
                x = math.random(rad, Core.screen.w - rad),
                y = -rad
            },
            color = { hue, hue + math.random(1, 10), 1, sat },
            maxOffset = rad / 7,
            speed = math.random(50, 150)
        }
        local newSnowflake = Snowflake:new(opts)
        table.insert(Core.snowflakes, newSnowflake)
        M.lastSpawned = 0
    end
end

return M
