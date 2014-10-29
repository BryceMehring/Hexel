-- TODO: clean this up!

require "source/utilities/vector"
require "source/utilities/extensions/math"
require "source/scenes/singlePlayer/enemy"
require "source/pathfinder"

local Towers = require "assets/towers"

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
    self.direction = 1
    
    self.sideSelect = -1
    self.selectName = ""
    self.selectCost = ""
    self.selectDamage = ""
    self.selectRange = ""
    self.selectDescription = ""

    self.currentCash = 200
    self.currentInterest = "0%"
    self.currentScore = 0
    self.layer = t.layer
    self.map = t.map
    
    self.updateStatus = t.updateStatus
    
    self:buildGrid()
end

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function game:generateStatus()
   return "Selected: " .. self.selectName .. 
          "\nCost:" .. self.selectCost ..
          "\n" .. self.selectDescription ..
          "\nRange:" .. self.selectRange .. "  Damage:".. self.selectDamage ..
          "\n\nCash: " .. self.currentCash
end

function game:buildGrid()
    self.width = self.map.width or self.width
    self.height = self.map.height or self.height
    self.default_tile = self.map.default_tile or self.default_tile
    
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
    
    for i, data in ipairs(self.map.tiles) do
        for j, pos in ipairs(data) do
            self.grid.grid:setTile(pos[1], pos[2], i)
        end
    end
    
    local targetPos = self.map.paths and self.map.paths[1][#self.map.paths[1]] or self.map.targetPosition
    self.path = not self.map.paths and findPath(self.grid.grid, vector{targetPos[1], targetPos[2]})
end

function game:run()
    local spawnColor = {1, 0, 0, 1}
    
    self.enemies = {}
    
    -- Timer controlling when enemies spawn
    local spawnTimer = flower.Executors.callLoopTime(0.5, function()
            
        -- Extract starting position from map
        local startPosition = self.map.paths and self.map.paths[1][1] or self.map.startPosition
        if type(startPosition) == "function" then startPosition = startPosition() end
        
        -- Convert starting position into world space
        startPosition = vector{self.grid.grid:getTileLoc(startPosition[1], startPosition[2], MOAIGridSpace.TILE_CENTER)}
  
        local newEnemy = enemy {
            layer = self.layer,
            width = 10, height = 10,
            pos = startPosition,
            color = spawnColor,
            speed = math.randomFloatBetween(2, 5),
            grid = self.grid.grid,
            map = self.map,
            path = self.path,
        }
        table.insert(self.enemies, newEnemy)
    end)

    -- Timer controlling when the enemies change color(in the future this could change the wave type)
    local colorTimer = flower.Executors.callLoopTime(4, function()
        spawnColor = math.generateRandomNumbers(0.1, 1, 4)
        spawnColor[4] = math.clamp(spawnColor[4], 0.95, 1.0)
    end)

    -- Timer to simulate the destruction of enemies
    --[[local destroyTimer = flower.Executors.callLoopTime(1, function()
        if #self.enemies > 0 then
            local randomEnemy = math.random(1, #self.enemies)
            self.enemies[randomEnemy]:remove()
            table.remove(self.enemies, randomEnemy)
        end
    end)]]

    self.timers = {}
    table.insert(self.timers, spawnTimer)
    table.insert(self.timers, destroyTimer)
    table.insert(self.timers, colorTimer)
    
    self:paused(false)
    flower.Executors.callLoop(self.loop, self)
end

function game:loop()
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
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

function game:onTouchDown(pos)
    local tile = self.grid:getTile(pos[1], pos[2])
    -- TODO: highlight map tile
    
    if tile == 5 and self.sideSelect ~= -1 then
        if self.currentCash >= Towers[self.sideSelect].cost then
            self.currentCash = self.currentCash - Towers[self.sideSelect].cost
            self.grid:setTile(pos[1], pos[2], self.sideSelect)
            
            self.updateStatus(self:generateStatus())
            -- TODO: update statusUI for cost
        else
            -- TODO: alert for insufficient funds
        end
    elseif tile ~= 5 then
        -- TODO: change statusUI for tower select from here
        -- TODO: upgrade and sell options appear
    end
    
end