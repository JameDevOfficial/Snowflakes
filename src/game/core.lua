local Core = {}

EXITED = -1
PAUSED = 0
LOADING = 1
INHELP = 5
INMENU = 11
INGAME = 12

Core.reset = function()

end

Core.load = function()
    Core.status = LOADING
    math.randomseed(os.time())
    Core.screen = UI.windowResized()
    Core.snowflakes = {}
    Core.snowflakeButtons = {}
    Core.hand = love.mouse.getSystemCursor("hand")
    Core.revealedButtons = 0
    Core.lastRevealedButtonTime = 0

    --Snowflake.generateSnowflakes(16, 10)
    Core.generateMemoryField(16, 50)
    Core.status = INGAME
    Core.map = Core.generateRandomMap(16)
    Core.printMap()
end

Core.update = function(dt)
    for i, btn in ipairs(Core.snowflakeButtons) do
        if btn.visible == false and btn.alpha > 0 then
            btn.alpha = btn.alpha - 0.01
        end
    end
    -- print(love.timer.getTime() .. " - " .. Core.lastRevealedButtonTime + Settings.buttons.delay)
    if Core.revealedButtons > 1 and love.timer.getTime() > Core.lastRevealedButtonTime + Settings.buttons.delay then
        for i, btn in ipairs(Core.snowflakeButtons) do
            btn.alpha = 1
            btn.visible = true
            Core.revealedButtons = 0
        end
    end
end

Core.keypressed = function(key, scancode, isrepeat)
    if key == "f5" then
        Settings.DEBUG = not Settings.DEBUG
    end
    if Core.status == INHELP then
        Core.status = INMENU
        return
    end
    if Core.status == INMENU then
        if key == "return" then
            Core.reset()
            Core.status = INGAME
        end
        if key == "h" or key == "H" then
            Core.status = INHELP
        end
    end

    if Core.status == INGAME then
        if key == "space" then
        end
    end
end

Core.mousepressed = function(x, y, button, istouch, presses)
    if Core.status ~= INGAME or Core.revealedButtons >= 2 or button ~= 1 then
        return
    end

    for i, btn in ipairs(Core.snowflakeButtons) do
        if btn.alpha == 1 and
            x > btn[1] and x < btn[1] + btn[3] and
            y > btn[2] and y < btn[2] + btn[3] then
            print("Button Pressed")
            btn.visible = false
            Core.lastRevealedButtonTime = love.timer.getTime()
            Core.revealedButtons = Core.revealedButtons + 1
            break
        end
    end
end

Core.mousemoved = function(x, y, dx, dy, istouch)
    if Core.status == INGAME then
        for i, button in ipairs(Core.snowflakeButtons) do
            if x > button[1] and x < button[1] + button[3] then
                if y > button[2] and y < button[2] + button[3] then
                    print("Mouse Hovering Button!")
                    love.mouse.setCursor(Core.hand)
                    break
                end
            else
                love.mouse.setCursor()
            end
        end
    end
end

function Core.generateRandomMap(amount)
    local pairs = {}
    local sideAmount = math.floor(math.sqrt(amount) + 0.999)
    for i = 1, amount / 2 do
        table.insert(pairs, i)
        table.insert(pairs, i)
    end
    for i = #pairs, 2, -1 do
        local j = math.random(1, i)
        pairs[i], pairs[j] = pairs[j], pairs[i]
    end

    local map = {}
    local index = 1
    for i = 1, sideAmount do
        local row = {}
        for j = 1, sideAmount do
            if index <= #pairs then
                table.insert(row, pairs[index])
                index = index + 1
            end
        end
        if #row > 0 then
            table.insert(map, row)
        end
    end
    return map
end

Core.generateMemoryField = function(amount, padding)
    local sideAmount = math.floor(math.sqrt(amount) + 0.999)
    local screen = Core.screen
    local xOffset = (screen.w - screen.minSize) / 2
    local yOffset = (screen.h - screen.minSize) / 2
    local sfWidth = (screen.minSize - (padding * sideAmount + padding)) / sideAmount
    local minOffset = sfWidth / 30
    local br = sfWidth / 20
    local bpadding = 10

    local processed = 0
    for i = 1, sideAmount, 1 do
        local sideAmount2 = sideAmount
        if processed + sideAmount > amount then sideAmount2 = amount % sideAmount end
        for j = 1, sideAmount2, 1 do
            local opts = {
                radius = sfWidth / 2,
                position = {
                    x = xOffset + (sfWidth * j - 1) + padding * j - sfWidth / 2,
                    y = yOffset + (sfWidth * i - 1) + padding * i - sfWidth / 2
                },
                maxOffset = math.random(minOffset, minOffset * 2.5),
            }
            table.insert(Core.snowflakes, Snowflake:new(opts))

            local x = opts.position.x - sfWidth / 2
            local y = opts.position.y - sfWidth / 2


            table.insert(Core.snowflakeButtons,
                { x - bpadding, y - bpadding, sfWidth + bpadding * 2, br, visible = true, alpha = 1 })
            processed = processed + 1
        end
        if sideAmount2 ~= sideAmount then return end
    end
end

function Core.drawSnowflakeButtons()
    for i, snowflake in ipairs(Core.snowflakeButtons) do
        love.graphics.setColor(1, 1, 1, snowflake.alpha)
        love.graphics.rectangle("fill", snowflake[1], snowflake[2], snowflake[3], snowflake[3], snowflake[4],
            snowflake[4])
    end
end

function Core.printMap()
    for i, row in ipairs(Core.map) do
        local line = ""
        for j, val in ipairs(row) do
            line = line .. string.format("%2d ", val)
        end
        print(line)
    end
end

return Core
