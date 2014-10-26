require "source/utilities/vector"
require "source/utilities/extensions/math"
require "source/scenes/singlePlayer/enemy"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

game = flower.class()

function game:init(t)
    -- TODO: pass is variables instead of hardcoding them
    self.texture = "hex-tiles.png"
    self.width = 50
    self.height = 100
    self.tileWidth = 128
    self.tileHeight = 111
    self.radius = 24
    self.default_tile = 0
    self.selectedTower = -1
    self.direction = 1

    self.currentCash = 200
    self.currentInterest = "0%"
    self.currentScore = 0
    self.layer = t.layer
    
    self:buildGrid()
end

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function game:generateStatus()
   return "Cash: " .. self.currentCash ..
        "\nInterest: " .. self.currentInterest ..
        "\nScore: " .. self.currentScore
end

function game:buildGrid()
    self.width = Map.width or self.width
    self.height = Map.height or self.height
    self.default_tile = Map.default_tile or self.default_tile
    
    self.grid = flower.MapImage(self.texture,
                                self.width, 
                                self.height,
                                self.tileWidth,
                                self.tileHeight,
                                self.radius)
                                  
    self.grid:setShape(MOAIGridSpace.HEX_SHAPE)
    self.grid:setLayer(self.layer)
    
    self.grid:setRepeat(false, false)
    self.grid:setPos(0,0)
    
    --print(self.height, self.width)
    for i = 1,self.width do
        for j = 1,self.height do
            self.grid.grid:setTile(i, j, self.default_tile)
        end
    end
    
    for i, data in ipairs(Map.tiles) do
        for j, pos in ipairs(data) do
            self.grid.grid:setTile(pos[1], pos[2], i)
        end
    end
end

function game:run()
    local x, y = self.grid.grid:getTileLoc(Map.paths[1][1][1], Map.paths[1][1][2], MOAIGridSpace.TILE_CENTER)
    local spawnColor = {1, 0, 0, 1}
    
    self.enemies = {}
    local spawnTimer = flower.Executors.callLoopTime(0.5, function()
        local newEnemy = enemy {
            width = 10, height = 10,
            pos = {x, y},
            color = spawnColor,
            layer = self.layer,
            pathIndex = 1,
            speed = math.randomFloatBetween(2, 5),
            grid = self.grid.grid,
        }
        table.insert(self.enemies, newEnemy)
    end)

    local colorTimer = flower.Executors.callLoopTime(4, function()
        spawnColor = math.generateRandomNumbers(0.1, 1, 4)
        spawnColor[4] = math.clamp(spawnColor[4], 0.95, 1.0)
    end)

    local destroyTimer = flower.Executors.callLoopTime(1, function()
        if #self.enemies > 0 then
            local randomEnemy = math.random(1, #self.enemies)
            self.enemies[randomEnemy]:remove()
            table.remove(self.enemies, randomEnemy)
        end
    end)

    self.timers = {}
    table.insert(self.timers, spawnTimer)
    table.insert(self.timers, destroyTimer)
    table.insert(self.timers, colorTimer)
    
    self:paused(false)
    flower.Executors.callLoop(self.loop, self)
end

function game:loop()
    
    for i, enemy in ipairs(self.enemies) do
        if not enemy:update() then
            enemy:remove()
            table.remove(self.enemies, i)
        end
    end
    
    while self:paused() do
        coroutine.yield()
    end
    
    return self:stopped()
end

function game:paused(p)
    if p ~= nil then

        for i, timer in ipairs(self.timers) do
            if p then
                timer:pause()
            else
                timer:start()
            end
        end

        self.isPaused = p
    else
        return self.isPaused
    end
end

function game:stopped(s)
    if s ~= nil then
        
        if s == true then
            for i, timer in ipairs(self.timers) do
                flower.Executors.cancel(timer)
            end
            
            for i, enemy in ipairs(self.enemies) do
                enemy:remove()
            end
        end
        
        self.isStopped = s
    else
        return self.isStopped
    end
end