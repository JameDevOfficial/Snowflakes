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
    o.points   = M:createRandomShape(10, 50, 100, 0, 0)
    o.mesh     = love.graphics.newMesh(#o.points * 2 + 2, "fan", "static")
    o.mesh:setVertices(o.points)

    return o
end

function M:update()

end

function M:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.rotate(self.rotation)
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(2)
    local scale = self.scale or 1
    love.graphics.draw(self.mesh, 0, 0, 0, scale, scale)
    love.graphics.pop()
end

function M:createRandomShape(points, minRadius, maxRadius, cx, cy)
    local vertices = {}
    print(points)
    local angleStep = 2 * math.pi / (points * 2)
    table.insert(vertices, { cx, cy })
    local firstCord = nil
    for i = 1, points * 2 do
        local angle = (i - 1) * angleStep
        local radius = math.random(minRadius, maxRadius)
        local x = cx + math.cos(angle) * radius
        local y = cy + math.sin(angle) * radius
        if firstCord == nil then firstCord = { x, y } end
        table.insert(vertices, { x, y })
    end
    table.insert(vertices, firstCord)
    return vertices
end

return M
