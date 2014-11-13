-- TODO: clean this up!

require "source/utilities/vector"
require "source/utilities/extensions/math"
require "source/scenes/singlePlayer/enemy"
require "source/scenes/singlePlayer/tower"
require "source/pathfinder"

local Towers = require "assets/towers"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

local bgm = MOAIUntzSound.new();
bgm:load("assets/sounds/EPICSaxGuyLoop.wav")
bgm:setVolume(.1)
bgm:setLooping(true)

Game = flower.class()

function Game:init(t)
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

    self.currentCash = 200000
    self.currentInterest = 0
    self.currentScore = 0
    self.layer = t.layer
    self.map = t.map
    
    self.towers = {}
    self.attacks = {}
    
    self.currentWave = 1
    
    self.updateStatus = t.updateStatus
    self.view = t.view
    
    self:buildGrid()
    
    bgm:play()
end

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function Game:generateItemInfo()
    if self.selectName ~= "" then
        return "Selected: " .. self.selectName .. 
               "\nCost:" .. self.selectCost ..
               "\n" .. self.selectDescription ..
               "\nRange:" .. self.selectRange .. 
               "  Damage:".. self.selectDamage
    else
       return "" 
    end
end

function Game:generateStatus()
   return "Curent Wave: " .. self.currentWave ..
          "\nCash: " .. self.currentCash ..
          "  Interest: " .. self.currentInterest .. "%" ..
          "\nScore: " .. self.currentScore
end

function Game:buildGrid()
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

function Game:run()
    local spawnColor = {1, 0, 0, 1}
    
    self.enemies = {}
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
    
    -- Timer controlling when enemies spawn
    local spawnTimer = flower.Executors.callLoopTime(self.map.waves[self.currentWave].spawnRate, function()
            
        -- Extract starting position from map
        local startPosition = self.map.paths and self.map.paths[1][1] or self.map.startPosition
        if type(startPosition) == "function" then startPosition = startPosition() end
        
        -- Convert starting position into world space
        startPosition = vector{self.grid.grid:getTileLoc(startPosition[1], startPosition[2], MOAIGridSpace.TILE_CENTER)}
  
        local newEnemy = Enemy {
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
        self.spawnedEnemies = self.spawnedEnemies + 1
        if self.spawnedEnemies >= self.map.waves[self.currentWave].length then
            self.timers.spawnTimer:pause()
            --spawnTimer:pause()
        end
    end)

    --[[local waveTimer = flower.Executors.callLoopTime(self.map.waves[self.currentWave].length, function()
        spawnTimer:pause()
    end)]]

    -- Timer controlling when the enemies change color(in the future this could change the wave type)
    local colorTimer = flower.Executors.callLoopTime(4, function()
        spawnColor = math.generateRandomNumbers(0.1, 1, 4)
        spawnColor[4] = math.clamp(spawnColor[4], 0.95, 1.0)
    end)

    self.timers = {
        spawnTimer = spawnTimer,
        colorTimer = colorTimer,
    }
    
    self:paused(false)
    flower.Executors.callLoop(self.loop, self)
end

function Game:updateWave()
    self:paused(true)
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
   
    self.currentWave = (self.currentWave + 1)
    if self.currentWave > #self.map.waves then
        self.currentWave = 1
    end
    
    self.timers.spawnTimer:setSpan(self.map.waves[self.currentWave].spawnRate)
    
    self:updateGUI()
    updatePauseButton()
    
    -- TODO: move this code somewhere else?
    local msgbox = widget.MsgBox {
        size = {flower.viewWidth / 2, 100},
        pos = {flower.viewWidth / 5, flower.viewHeight / 2},
        text = "Wave: " .. self.currentWave,
        parent = self.view,
        priority = 100,
    }
    
    msgbox:showPopup()
    flower.Executors.callLaterTime(3, function() msgbox:hidePopup() end)
end

function Game:loop()
    
    if self.enemiesKilled == self.map.waves[self.currentWave].length then
        -- increment  to the next wave
        self:updateWave()
    end
        
    
    for i = #self.attacks, 1, -1 do
        self.attacks[i]:setVisible(false)
        table.remove(self.attacks, i)
    end
    
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        local enemyStatus = enemy:update()
        if enemyStatus ~= Enemy.CONTINUE then
            
            --[[if enemyStatus == Enemy.DIED then
                self.enemiesKilled = self.enemiesKilled + 1
            end]]
            self.enemiesKilled = self.enemiesKilled + 1
            
            enemy:remove()
            table.remove(self.enemies, i)
        end
    end
    
    for key, tower in pairs(self.towers) do
        local result = tower:fire(self.enemies)
        if result ~= nil then
            v1 = vector{self.grid.grid:getTileLoc(tower.pos[1], tower.pos[2])}
            v2 = vector{self.enemies[result].rectangle:getPos()}
            local attack = Line({{x=v1[1], y=v1[2]}, {x=v2[1], y=v2[2]}})
            attack:setColor(1,1,1,1)
            attack:setLayer(self.layer)
            attack:setVisible(true)
            table.insert(self.attacks, #self.attacks, attack)
        end
    end
    
    while self:paused() do
        coroutine.yield()
    end
    
    return self:stopped()
end

function Game:paused(p)
    if p ~= nil then

        for k, timer in pairs(self.timers) do
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

function Game:stopped(s)
    if s ~= nil then
        
        if s == true then
            for k, timer in pairs(self.timers) do
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

function Game:updateGUI()
    self.updateStatus(self:generateStatus())
end

--TODO: clean this up
function Game:onTouchDown(pos)
    local tile = self.grid:getTile(pos[1], pos[2])
    -- TODO: highlight map tile
    
    if tile == 5 and self.sideSelect ~= -1 then
        if self.currentCash >= Towers[self.sideSelect].cost then
            self.currentCash = self.currentCash - Towers[self.sideSelect].cost
            self.grid:setTile(pos[1], pos[2], self.sideSelect)
            self.towers[Tower.serialize_pos(pos)] = Tower(self.sideSelect, pos)
            self:updateGUI()
            -- TODO: update statusUI for cost
        else
            -- TODO: alert for insufficient funds
        end
    elseif tile ~= 5 then
        -- TODO: change statusUI for tower select from here
        -- TODO: upgrade and sell options appear
    end
    
end