-- ⠀⠀⡀⠀⠀⠀⣀⣠⣤⣤⣤⣤⣤⣤⣤⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠘⢿⣝⠛⠋⠉⠉⠉⣉⠩⠍⠉⣿⠿⡭⠉⠛⠃⠲⣞⣉⡙⠿⣇⠀⠀⠀
-- ⠀⠀⠈⠻⣷⣄⡠⢶⡟⢁⣀⢠⣴⡏⣀⡀⠀⠀⣠⡾⠋⢉⣈⣸⣿⡀⠀⠀
-- ⠀⠀⠀⠀⠙⠋⣼⣿⡜⠃⠉⠀⡎⠉⠉⢺⢱⢢⣿⠃⠘⠈⠛⢹⣿⡇⠀⠀
-- ⠀⠀⠀⢀⡞⣠⡟⠁⠀⠀⣀⡰⣀⠀⠀⡸⠀⠑⢵⡄⠀⠀⠀⠀⠉⠀⣧⡀
-- ⠀⠀⠀⠌⣰⠃⠁⣠⣖⣡⣄⣀⣀⣈⣑⣔⠂⠀⠠⣿⡄⠀⠀⠀⠀⠠⣾⣷
-- ⠀⠀⢸⢠⡇⠀⣰⣿⣿⡿⣡⡾⠿⣿⣿⣜⣇⠀⠀⠘⣿⠀⠀⠀⠀⢸⡀⢸
-- ⠀⠀⡆⢸⡀⠀⣿⣿⡇⣾⡿⠁⠀⠀⣹⣿⢸⠀⠀⠀⣿⡆⠀⠀⠀⣸⣤⣼
-- ⠀⠀⢳⢸⡧⢦⢿⣿⡏⣿⣿⣦⣀⣴⣻⡿⣱⠀⠀⠀⣻⠁⠀⠀⠀⢹⠛⢻
-- ⠀⠀⠈⡄⢷⠘⠞⢿⠻⠶⠾⠿⣿⣿⣭⡾⠃⠀⠀⢀⡟⠀⠀⠀⠀⣹⠀⡆
-- ⠀⠀⠀⠰⣘⢧⣀⠀⠙⠢⢤⠠⠤⠄⠊⠀⠀⠀⣠⠟⠀⠀⠀⠀⠀⢧⣿⠃
-- ⠀⣀⣤⣿⣇⠻⣟⣄⡀⠀⠘⣤⣣⠀⠀⠀⣀⢼⠟⠀⠀⠀⠀⠀⠄⣿⠟⠀
-- ⠿⠏⠭⠟⣤⣴⣬⣨⠙⠲⢦⣧⡤⣔⠲⠝⠚⣷⠀⠀⠀⢀⣴⣷⡠⠃⠀⠀
-- ⠀⠀⠀⠀⠀⠉⠉⠉⠛⠻⢛⣿⣶⣶⡽⢤⡄⢛⢃⣒⢠⣿⣿⠟⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠁⠀⠁⠀⠀⠀⠀⠀
-- "Here she comes! Keep testing! Remember: you never saw me!"

local Core = {}
Core.gameStarted = 0
Core.finalTime = 0

EXITED = -1
PAUSED = 0
LOADING = 1
INHELP = 5
INMENU = 11
INGAME = 12

Core.reset = function()
    Core.snowflakes = {}
    Core.snowflakeButtons = {}
    Core.revealedButtons = 0
    Core.lastRevealedButtonTime = 0
    Core.map = MemoryGame.generateRandomMap(16)
    MemoryGame.generateMemoryField(16, 50)
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
    Core.status = INMENU
    -- MemoryGame.printMap()
end

Core.update = function(dt)
    if Core.status == INMENU then
        Snowflake.spawnRandomSnowflakesBackground(dt)
        for i = #Core.snowflakes, 1, -1 do
            local snowflake = Core.snowflakes[i]
            if snowflake.position.y - snowflake.radius > Core.screen.h then
                table.remove(Core.snowflakes, i)
            else
                snowflake:update(dt)
            end
        end
    elseif Core.status == INGAME then
        MemoryGame.handleButtons()
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
            Core.gameStarted = love.timer.getTime()
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
                    -- print("Mouse Hovering Button!")
                    love.mouse.setCursor(Core.hand)
                    break
                end
            else
                love.mouse.setCursor()
            end
        end
    end
end

return Core
