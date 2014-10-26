require "source/utilities/vector"
require "source/utilities/extensions/math"
require "source/scenes/singlePlayer/enemy"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

-- Game singleton
-- TODO: turn this into a regular class, not a singleton
Game = {}
Game.texture = "hex-tiles.png"
Game.width = 50
Game.height = 100
Game.tileWidth = 128
Game.tileHeight = 111
Game.radius = 24
Game.default_tile = 0
Game.selectedTower = -1
Game.direction = 1

Game.currentCash = 200
Game.currentInterest = "0%"
Game.currentScore = 0

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function Game.generateStatus()
   return "Cash: " .. Game.currentCash ..
        "\nInterest: " .. Game.currentInterest ..
        "\nScore: " .. Game.currentScore
end

function Game.buildGrid()
    Game.width = Map.width or Game.width
    Game.height = Map.height or Game.height
    Game.default_tile = Map.default_tile or Game.default_tile
    
    Game.grid = flower.MapImage(Game.texture,
                                Game.width, 
                                Game.height,
                                Game.tileWidth,
                                Game.tileHeight,
                                Game.radius)
                                  
    Game.grid:setShape(MOAIGridSpace.HEX_SHAPE)
    Game.grid:setLayer(Game.layer)
    
    Game.grid:setRepeat(false, false)
    Game.grid:setPos(0,0)
    
    --print(Game.height, Game.width)
    for i = 1,Game.width do
        for j = 1,Game.height do
            Game.grid.grid:setTile(i, j, Game.default_tile)
        end
    end
    
    for i, data in ipairs(Map.tiles) do
        for j, pos in ipairs(data) do
            Game.grid.grid:setTile(pos[1], pos[2], i)
        end
    end
end

function Game.run()
    local x, y = Game.grid.grid:getTileLoc(Map.paths[1][1][1], Map.paths[1][1][2], MOAIGridSpace.TILE_CENTER)
    local spawnColor = {1, 0, 0, 1}
    
    Game.enemies = {}
    local spawnTimer = flower.Executors.callLoopTime(0.5, function()
        local newEnemy = enemy {
            width = 10, height = 10,
            pos = {x, y},
            color = spawnColor,
            layer = Game.layer,
            pathIndex = 1,
            speed = math.randomFloatBetween(2, 5)
        }
        table.insert(Game.enemies, newEnemy)
    end)

    local colorTimer = flower.Executors.callLoopTime(4, function()
        spawnColor = math.generateRandomNumbers(0.1, 1, 4)
        spawnColor[4] = math.clamp(spawnColor[4], 0.9, 1.0)
    end)

    local destroyTimer = flower.Executors.callLoopTime(1, function()
        if #Game.enemies > 0 then
            local randomEnemy = math.random(1, #Game.enemies)
            Game.enemies[randomEnemy]:remove()
            table.remove(Game.enemies, randomEnemy)
        end
    end)

    Game.timers = {}
    table.insert(Game.timers, spawnTimer)
    table.insert(Game.timers, destroyTimer)
    table.insert(Game.timers, colorTimer)
    
    Game.paused(false)
    flower.Executors.callLoop(Game.loop)
end

function Game.loop()
    
    for i, enemy in ipairs(Game.enemies) do
        if not enemy:update() then
            enemy:remove()
            table.remove(Game.enemies, i)
        end
    end
    
    while Game.paused() do
        coroutine.yield()
    end
    
    return Game.stopped()
end

function Game.paused(p)
    if p ~= nil then

        for i, timer in ipairs(Game.timers) do
            if p then
                timer:pause()
            else
                timer:start()
            end
        end

        Game.isPaused = p
    else
        return Game.isPaused
    end
end

function Game.stopped(s)
    if s ~= nil then
        
        if s == true then
            for i, timer in ipairs(Game.timers) do
                flower.Executors.cancel(timer)
            end
            
            for i, enemy in ipairs(Game.enemies) do
                enemy:remove()
            end
        end
        
        Game.isStopped = s
    else
        return Game.isStopped
    end
end