local Core = {}

EXITED = -1
PAUSED = 0
LOADING = 1
INHELP = 5
-- Below are all fine during game
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

    --Snowflake.generateSnowflakes(16, 10)
    Core.generateMemoryField(16, 50)
    Core.status = INMENU
end

Core.update = function(dt)
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
    if Core.status == INGAME then
        if button == 1 then --lmb
            for i, button in ipairs(Core.snowflakeButtons) do
                if x > button[1] and x < button[1] + button[3] then
                    if y > button[2] and y < button[2] + button[3] then
                        print("Button Pressed")
                        break
                    end
                end
            end
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

Core.generateMemoryField = function(amount, padding)
    local sideAmount = math.floor(math.sqrt(amount) + 0.99)
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


            table.insert(Core.snowflakeButtons, { x - bpadding, y - bpadding, sfWidth + bpadding * 2, br })
            processed = processed + 1
        end
        if sideAmount2 ~= sideAmount then return end
    end
end

function Core.drawSnoflakeButtons()
    for i, snowflake in ipairs(Core.snowflakeButtons) do
        love.graphics.rectangle("line", snowflake[1], snowflake[2], snowflake[3], snowflake[3], snowflake[4],
            snowflake[4])
    end
end

return Core
