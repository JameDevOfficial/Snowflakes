local M = {}
M.__index = M

function M:new(opts)
    opts       = opts or {}
    local o    = setmetatable({}, self)
    o.type     = "snowflake"
    o.size     = opts.size or Settings.snowflake.size
    o.scale    = opts.scale or 1
    o.color    = opts.color or { 1, 1, 1, 1 }
    o.position = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.rotation = opts.rotation or 0
    o.points   = M:createRandomShape(400, 25, Core.screen.centerX, Core.screen.centerY)
    for i = 1, 2 do
        table.remove(o.points, 1)
    end
    o.mesh    = love.graphics.newMesh(#o.points * 2 + 2, "fan", "static")
    o.dotMesh = love.graphics.newMesh(#o.points * 2 + 2, "points", "static")
    --o.mesh:setVertices(o.points)
    --o.dotMesh:setVertices(o.points)

    return o
end

function M:update()

end

function M:render()
    love.graphics.push();
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.points)
    love.graphics.pop()
end

function M:createRandomShape(radius, maxOffset, cx, cy)
    local branches = 8 + 2 * math.random(1, 4)
    local pointsPerBranch = 16 + 2 * math.random(1, 4)
    local pointsPerBranchSide = pointsPerBranch / 2
    local lastPoint = nil
    print("Branches: " .. branches .. "\nPoints Per Branch: " .. pointsPerBranch)

    --Half branch
    local halfBranch = {}
    for i = 1, pointsPerBranchSide do
        local t = i / pointsPerBranchSide
        local r = radius * t
        local lateralOffset = math.random(0, maxOffset)
        local x = math.cos(0) * r + math.sin(0) * lateralOffset
        local y = math.sin(0) * r - math.cos(0) * lateralOffset
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

    -- Branches
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

return M
