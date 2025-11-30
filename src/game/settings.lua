local M = {}

M.DEBUG = false

M.snowflake = {}
M.snowflake.size = { 100, 100 }
M.snowflake.spawnDelay = 0.5 -- s
M.snowflake.spawnChance = 75 -- %
M.snowflake.speed = 10

M.buttons = {}
M.buttons.delay = 2

M.fonts = {}
M.fonts.quirkyRobot = "assets/fonts/QuirkyRobot.ttf"
M.fonts.semiCoder = "assets/fonts/SemiCoder.otf"
M.fonts.courierPrimeCode = "assets/fonts/CourierPrimeCode/Courier Prime Code.ttf"
M.collision = {}
M.collision.enemy = 2
M.collision.projectile = 4
M.collision.centerFrame = 8
return M;
