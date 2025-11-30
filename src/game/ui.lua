local UI = {}

local fontDefault = love.graphics.newFont(20)
local font30 = love.graphics.newFont(30)
local font50 = love.graphics.newFont(50)
local titleFont = love.graphics.newFont(Settings.fonts.quirkyRobot, 128, "normal", love.graphics.getDPIScale())
local textFont = love.graphics.newFont(Settings.fonts.semiCoder, 32, "normal", love.graphics.getDPIScale())
local textFontBig = love.graphics.newFont(Settings.fonts.semiCoder, 46, "normal", love.graphics.getDPIScale())

titleFont:setFilter("nearest", "nearest")
textFont:setFilter("nearest", "nearest")
fontDefault:setFilter("nearest", "nearest")
font30:setFilter("nearest", "nearest")
font50:setFilter("nearest", "nearest")

UI.draw = function()
    if Core.status == INGAME then
        UI.drawGame()
    elseif Core.status == INMENU then
        UI.drawMenu()
    elseif Core.status == INHELP then
        UI.drawHelp()
    end
    if Settings.DEBUG then
        UI.drawDebug()
    end
end

UI.drawGame = function()
    for i, snowflake in pairs(Core.snowflakes) do
        snowflake:render()
    end
    MemoryGame.drawSnowflakeButtons()

    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 1)
    local ms, s, m
    local text = UI.secondsToFormat(love.timer.getTime() - Core.gameStarted)
    local width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, Core.screen.w - width - 10, 10)
end

UI.drawHelp = function()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(textFontBig)
    local currentY = 100

    local text = string.format("Gameplay: ")
    local width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, (Core.screen.w - width) / 2, currentY)
    currentY = currentY + height + 10

    love.graphics.setFont(textFont)
    local text = string.format(
        "This is a memory game.\nYou need to remind each snowflake and \ntry to find its matching partner. \nStart the game by pressing enter in the menu and \nreveal the memory tiles by clicking \non them with your mouse.\n\nHave fun! ~ Jame")
    local width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, (Core.screen.w - width) / 2, currentY)
    currentY = currentY + height

    text = "Press any key to return"
    width = textFont:getWidth(text)
    love.graphics.print(text, (Core.screen.w - width) / 2, (Core.screen.centerY - height) * 2)
end

UI.drawMenu = function()
    for i, snowflake in pairs(Core.snowflakes) do
        snowflake:render()
    end
    love.graphics.setColor(0.7, 0.95, 1)
    love.graphics.setFont(titleFont)
    local text = "Snowflakes"
    local width = titleFont:getWidth(text)
    love.graphics.print(text, (Core.screen.w - width) / 2, Core.screen.centerY - 200)

    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 1)
    local ms, s, m
    local text = UI.secondsToFormat(Core.finalTime)
    width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, (Core.screen.w - width) / 2, Core.screen.centerY - 100)


    text = "Press 'enter' to start - 'h' for help"
    local isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    if isMobile then
        text = "Touch to start"
    end
    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 1)
    width = textFont:getWidth(text)
    local height = textFont:getHeight()
    love.graphics.print(text, (Core.screen.w - width) / 2, (Core.screen.centerY - height) * 2)
end

UI.drawDebug = function()
    if Settings.DEBUG == true then
        love.graphics.setFont(fontDefault)

        local y = fontDefault:getHeight() + 10

        love.graphics.setColor(1, 0.1, 0.1)
        love.graphics.print("Disable (F5) Debug Mode for more FPS")
        y = y + fontDefault:getHeight()

        love.graphics.setColor(1, 1, 1, 1)
        -- FPS
        local fps = love.timer.getFPS()
        local fpsText = string.format("FPS: %d", fps)
        love.graphics.print(fpsText, 10, y)
        y = y + fontDefault:getHeight()

        -- Performance
        local stats = love.graphics.getStats()
        local usedMem = collectgarbage("count")
        local perfText = string.format(
            "Memory: %.2f MB\n" ..
            "GC Pause: %d%%\n" ..
            "Draw Calls: %d\n" ..
            "Canvas Switches: %d\n" ..
            "Texture Memory: %.2f MB\n" ..
            "Images: %d\n" ..
            "Fonts: %d\n",
            usedMem / 1024,
            collectgarbage("count") > 0 and collectgarbage("count") / 7 or 0,
            stats.drawcalls,
            stats.canvasswitches,
            stats.texturememory / 1024 / 1024,
            stats.images,
            stats.fonts
        )
        love.graphics.print(perfText, 10, y)
        y = y + fontDefault:getHeight() * 8

        -- Game
        local dt = love.timer.getDelta()
        local avgDt = love.timer.getAverageDelta()

        local playerText = string.format(
            "Game state: %s\n" ..
            "Delta Time: %.4fs (%.1f ms)\n" ..
            "Avg Delta: %.4fs (%.1f ms)\n" ..
            "Time: %.2fs\n" ..
            "Snowflakes: %03d\n",
            tostring(Core.status),
            dt, dt * 1000,
            avgDt, avgDt * 1000,
            love.timer.getTime(),
            #Core.snowflakes
        )
        love.graphics.print(playerText, 10, y)
        y = y + fontDefault:getHeight() * 5

        -- System Info
        local renderer = love.graphics.getRendererInfo and love.graphics.getRendererInfo() or ""
        local systemText = string.format(
            "OS: %s\nGPU: %s",
            love.system.getOS(),
            select(4, love.graphics.getRendererInfo()) or 0
        )
        love.graphics.print(systemText, 10, y)
    end
end

function UI.secondsToFormat(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    local ms = math.floor((seconds - math.floor(seconds)) * 1000)
    return string.format("%02d:%02d:%03d", m, s, ms)
end

UI.windowResized = function()
    local screen = {
        w = 0,
        h = 0,
        centerX = 0,
        centerY = 0,
        minSize = 0,
        topLeft = { X = 0, Y = 0 },
        topRight = { X = 0, Y = 0 },
        bottomLeft = { X = 0, Y = 0 },
        bottomRight = { X = 0, Y = 0 }
    }
    screen.w, screen.h = love.graphics.getDimensions()
    screen.minSize = (screen.h < screen.w) and screen.h or screen.w
    screen.centerX = screen.w / 2
    screen.centerY = screen.h / 2

    local half = screen.minSize / 2
    screen.topLeft.X = screen.centerX - half
    screen.topLeft.Y = screen.centerY - half
    screen.topRight.X = screen.centerX + half
    screen.topRight.Y = screen.centerY - half
    screen.bottomRight.X = screen.centerX + half
    screen.bottomRight.Y = screen.centerY + half
    screen.bottomLeft.X = screen.centerX - half
    screen.bottomLeft.Y = screen.centerY + half

    return screen
end

return UI
