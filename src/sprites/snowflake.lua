local M = {}
M.__index = M

function M:new(opts)
    opts       = opts or {}
    local o    = setmetatable({}, self)
    o.type     = "snowflake"
    o.size     = opts.size or Settings.player.size
    o.scale    = opts.scale or 1
    o.color    = opts.color or { 1, 1, 1, 1 }
    o.position = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.rotation = opts.rotation or 0

    return o
end

function M:render()
    if not self.body then return end
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

function M:createRandomShape()

end

return M
