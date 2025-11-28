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
    math.randomseed(os.time())
    Core.status = LOADING

    Core.screen = UI.windowResized()
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

    end
end

return Core
