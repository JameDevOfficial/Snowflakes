local M = {}

function M.generateRandomMap(amount)
    if (amount / 2) % 1 ~= 0 then
        error("Core.generateRandomMap\nInvalid argument: amount(" .. amount .. ") must be a multiple of 2")
        return
    end
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

M.generateMemoryField = function(amount, padding)
    if (amount / 2) % 1 ~= 0 then
        error("Core.generateMemoryField\nInvalid argument: amount(" .. amount .. ") must be a multiple of 2")
        return
    end
    local sideAmount = math.floor(math.sqrt(amount) + 0.999)
    local screen = Core.screen
    local xOffset = (screen.w - screen.minSize) / 2
    local yOffset = (screen.h - screen.minSize) / 2
    local sfWidth = (screen.minSize - (padding * sideAmount + padding)) / sideAmount
    local minOffset = sfWidth / 30
    local br = sfWidth / 20
    local bpadding = 10

    local processedSnowflakesPointsWithId = {}
    for i = 1, amount / 2 do
        processedSnowflakesPointsWithId[i] = nil
    end

    for i, row in ipairs(Core.map) do
        for j, id in ipairs(row) do
            local points = processedSnowflakesPointsWithId[id]
            if not points then
                local opts = {
                    radius = sfWidth / 2,
                    position = {
                        x = xOffset + (sfWidth * j - 1) + padding * j - sfWidth / 2,
                        y = yOffset + (sfWidth * i - 1) + padding * i - sfWidth / 2
                    },
                    maxOffset = math.random(minOffset, minOffset * 2.5),
                }
                points = Snowflake:new(opts).points
                processedSnowflakesPointsWithId[id] = points
            end

            local opts = {
                radius = sfWidth / 2,
                position = {
                    x = xOffset + (sfWidth * j - 1) + padding * j - sfWidth / 2,
                    y = yOffset + (sfWidth * i - 1) + padding * i - sfWidth / 2
                },
                maxOffset = math.random(minOffset, minOffset * 2.5),
                points = points
            }
            local newSnowflake = Snowflake:new(opts)
            table.insert(Core.snowflakes, newSnowflake)

            local x = opts.position.x - sfWidth / 2
            local y = opts.position.y - sfWidth / 2
            local saturation = math.random(50, 90) / 100

            table.insert(Core.snowflakeButtons,
                {
                    x - bpadding,
                    y - bpadding,
                    sfWidth + bpadding * 2,
                    br,
                    visible = true,
                    alpha = 1,
                    mapID = id,
                    color = { saturation, saturation + math.random(1, 10) / 10, 1 },
                    mode =
                    "fill"
                })
        end
    end
end

function M.drawSnowflakeButtons()
    for i, snowflake in ipairs(Core.snowflakeButtons) do
        love.graphics.setColor(snowflake.color[1], snowflake.color[2], snowflake.color[3], snowflake.alpha)
        local mode = snowflake.mode
        if Settings.DEBUG then mode = "line" end
        love.graphics.rectangle(mode, snowflake[1], snowflake[2], snowflake[3], snowflake[3], snowflake[4],
            snowflake[4])
    end
end

function M.printMap()
    for i, row in ipairs(Core.map) do
        local line = ""
        for j, val in ipairs(row) do
            line = line .. string.format("%2d ", val)
        end
        print(line)
    end
end

function M.handleButtons()
    for i, btn in ipairs(Core.snowflakeButtons) do
        if btn.visible == false and btn.alpha > 0 then
            btn.alpha = btn.alpha - 0.01
        end
    end
    -- print(love.timer.getTime() .. " - " .. Core.lastRevealedButtonTime + Settings.buttons.delay)
    if Core.revealedButtons > 1 and love.timer.getTime() > Core.lastRevealedButtonTime + Settings.buttons.delay then
        local ids = {}
        local btns = {}
        for i, btn in ipairs(Core.snowflakeButtons) do
            if btn.visible == false then
                table.insert(ids, btn.mapID)
                table.insert(btns, btn)
            end
        end
        Core.revealedButtons = 0
        if ids[1] == ids[2] then
            for _, btn in ipairs(btns) do
                print("Changed btn " .. ids[1])
                btn.color = { 0.2, 1, 0.2 }
                btn.mode = "line"
            end
        end
        btns[1].visible = true
        btns[1].alpha = 1
        btns[2].visible = true
        btns[2].alpha = 1


        if M.isSolved() then
            print("Game solved!")
            Core.status = INMENU
            Core.finalTime = love.timer.getTime() - Core.gameStarted
        end
    end
end

function M.isSolved()
    for _, btn in ipairs(Core.snowflakeButtons) do
        if btn.visible ~= true or btn.mode ~= "line" then
            return false
        end
    end
    return true
end

return M
