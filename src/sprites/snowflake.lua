local M = {}
M.__index = M

function M:new(opts)
    opts          = opts or {}
    local o       = setmetatable({}, self)
    o.type        = "snowflake"
    o.size        = opts.size or Settings.player.size
    o.color       = opts.color or { 1, 1, 1, 1 }
    o.position    = opts.position or { x = Core.screen.centerX, y = Core.screen.centerY }
    o.rotation    = opts.rotation or 0

    return o
end

function M:createRandomShape()

end

return M