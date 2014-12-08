--------------------------------------------------------------------------------
-- game.lua - Defines a game which(for now) manages the game logic for a single player game
--------------------------------------------------------------------------------
-- TODO: clean this up!

require "source/utilities/vector"
require "source/utilities/extensions/math"
require "source/game/wave"
require "source/game/enemy"
require "source/game/tower"
require "source/pathfinder"
require "source/game/map"
require "source/sound/sound"
require "assets/enemies/enemyTypes"

local Towers = require "assets/towers/towers"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

Game = flower.class()
--Add 3% to the interest rate each turn
Game.INTEREST_INCREMENT = 3 

function Game:init(t)
    -- TODO: pass is variables instead of hardcoding them
    self.texture = "hex-tiles.png"
    self.tileWidth = 128
    self.tileHeight = 111
    self.radius = 24
    self.default_tile = 0
    self.direction = 1
    self.layer = t.layer
    self.mapFile = t.mapFile
    
    self.view = t.view
    self.popupView = t.popupView
    
    self.soundManager = SoundManager {
       soundDir = "assets/sounds/soundtrack/",
    }
    self.soundManager:randomizedPlay()
    
    -- BEGIN Necessary Client Data
    self.width = 50
    self.height = 100
    self.currentLives = 20
    self.currentCash = 5000
    self.currentInterest = 0
    
    self.towers = {}
    self.attacks = {}
    
    self.map = Map {
        file = self.mapFile,
        texture = self.texture,
        width = self.width,
        height = self.height,
        tileWidth = self.tileWidth,
        tileHeight = self.tileHeight,
        radius = self.radius,
        layer = self.layer,
    }
    
    self.difficulty = 1
    self.currentWave = Wave {
        number = 0, 
        difficulty = self.difficulty, 
        --layer = self.layer, 
        --map = self.map
    }
    -- END Necessary Client Data
end

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function Game:generateItemInfo()
    return self.towerSelected and self.towerSelected:getDescription() or ""
end

function Game:generateStatus()
   return "Wave: " .. self.currentWave.number ..
          "  Lives: " .. self.currentLives ..
          "\nCash: " .. self.currentCash ..
          "  Interest: " .. self.currentInterest .. "%"
end


function Game:getPopupPos()
    return {flower.viewWidth / 5, flower.viewHeight / 2}
end 

function Game:getPopupSize()
    return {flower.viewWidth / 2, 100}
end

-- Initializes the game to run by turning on the spawning of enemies
function Game:run()    
    self.enemies = {}
    self.enemiesToSpawn = {}
    
    self:paused(true)
    
    flower.Executors.callLoop(self.loop, self)
end


-- Main game loop which updates all of the entities in the game
function Game:loop()
    while self:paused() do
        coroutine.yield()
    end
    
    --if self.enemiesKilled == self.map:getWaves()[self.currentWave].length then
    if #self.enemiesToSpawn == 0 and #self.enemies == 0 then
        if self.currentWave.number > 0 then
            self.currentInterest = self.currentInterest + Game.INTEREST_INCREMENT
            self.currentCash = math.floor(self.currentCash * (1+self.currentInterest/100))
        end
        
        -- increment to the next wave
        self:setupNextWave()
    end
        
    -- TODO: move the laser into its own class
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        local enemyStatus = enemy:update()
        if enemyStatus ~= Enemy.CONTINUE then
            self.enemiesKilled = self.enemiesKilled + 1
            if enemyStatus == Enemy.DIED then
                self.currentCash = self.currentCash + enemy:getCost()
            else
                self:loseLife()
            end
            
            enemy:remove()
            table.remove(self.enemies, i)
        end
    end
    
    -- TODO: clean this up!
    for key, tower in pairs(self.towers) do
        local result = tower:fire(self.enemies)
        if result ~= nil then
            local v1 = self.map:gridToScreenSpace(tower.pos)
            local v2 = vector{self.enemies[result].group:getPos()}
            local attack = Line({{x=v1[1], y=v1[2]}, {x=v2[1], y=v2[2]}})
            attack:setColor(1,1,1,1)
            attack:setLayer(self.layer)
            attack:setVisible(true)
            flower.Executors.callLaterFrame(0.1, function()
                attack:setLayer(nil)
                attack:setVisible(false)
            end)
        end
    end
    
    self:updateGUI()
    
    return self:stopped()
end

function Game:setupNextWave()
    self:paused(true)
    
    self.currentWave:increment()
    
    -- TODO: add an option so that the game keeps on going, like a survival mode, issue #51
    if self.currentWave:currentNumber() > 50 then
        self:showEndGameMessage("You've Won the main game")
    end
    
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
    self.enemies = {}
    
    self.currentWave:setup()
    self.enemiesToSpawn = self.currentWave:getEnemies()
    
    self:updateGUI()
    
    local msgBox = generateMsgBox(
        self:getPopupPos(), 
        self:getPopupSize(), 
        "Wave: " .. self.currentWave.number, 
        self.popupView)
    
    msgBox:showPopup()
    flower.Executors.callLaterTime(3, function()
        msgBox:hidePopup()
        self.popupView:removeChild(msgBox)
        self:startSpawnLoop()
        self:paused(false)
    end)
end

function Game:spawnLoop()
    if self:stopped() then
        return
    end
        
    if #self.enemiesToSpawn == 0 then
        self.timers.spawnTimer:pause()
        return true
    end
    
    local enemySpawn = table.remove(self.enemiesToSpawn)
    enemySpawn:spawn(self.layer, self.map)
    table.insert(self.enemies, enemySpawn)
    self.spawnedEnemies = self.spawnedEnemies + 1
end

function Game:startSpawnLoop()    
    local spawnRate = self.currentWave.time / #self.enemiesToSpawn
    local spawnTimer = flower.Executors.callLoopTime(spawnRate, self.spawnLoop, self)
    self.timers = {
        spawnTimer = spawnTimer,
    }
    
    self.timers.spawnTimer:start()
end

-- Looses a life and ends the game if the lives count reaches 0
function Game:loseLife()
    self.currentLives = self.currentLives - 1
    if self.currentLives <= 0 then
        self:showEndGameMessage("Game Over!")
    end
end

-- Pauses the game if p is true, unpauses the game if p is false
-- If p is nil, paused() return true if the game is paused
function Game:paused(p)
    if p ~= nil then

        if self.timers then
            for k, timer in pairs(self.timers) do
                if p then
                    timer:pause()
                else
                    timer:start()
                end
            end
        end
        
        self.isPaused = p
        updatePauseButton(not p, self.currentWave.number)
    else
        return self.isPaused
    end
end

-- Stops the game if s is true
-- Returns true if the game if s is nil
function Game:stopped(s)
    if s ~= nil then
        
        if s == true then
            self.soundManager:stop()
            if self.timers then
                for k, timer in pairs(self.timers) do
                    flower.Executors.cancel(timer)
                end
                
                for i, enemy in ipairs(self.enemies) do
                    enemy:remove()
                end
            end
        end
        
        self.isStopped = s
    else
        return self.isStopped
    end
end

function Game:updateGUI()
    updateStatusText(self:generateStatus())
    updateItemText(self:generateItemInfo())
end

-- Shows a message box with a message just before ending the game
function Game:showEndGameMessage(msg)
    local msgBox = generateMsgBox(self:getPopupPos(), self:getPopupSize(), msg, self.popupView)
    msgBox:showPopup()
    flower.Executors.callLaterTime(3, function()
        msgBox:hidePopup()
        self.popupView:removeChild(msgBox)
    end)
    self:stopped(true)
end

-- not self.map:isTileSelected() mouse has the circle
-- Updates the current tower selected
function Game:selectTower(tower)
    self.towerSelected = tower

    if self.hoverCircle and self.hoverCircle.layer ~= nil then
        self.hoverCircle:setLayer(nil)
    end
    
    if self.towerSelected then
        local screenPos = (self.towerSelected and self.towerSelected.pos) and self.map:gridToScreenSpace(self.towerSelected.pos) or self.cursorPos
        local range = self.map:gridToScreenSpace(tower.type.range) / 1.7 -- TODO: where does this number come from?
        
        if self.towerSelected.pos == nil then
            self:drawCircle(range, screenPos)
        else
            if self.hoverCircle == nil then
                self:drawCircle(range, screenPos)
            else
                if self.hoverCircle:getLeft() == screenPos[1] and self.hoverCircle:getTop() == screenPos[2] and self.map:isTileSelected() then
                    self.hoverCircle:setLayer(nil)
                    self.hoverCircle = nil
                else
                    self:drawCircle(range, screenPos)
                end
            end
        end
        self.map:unselectTile()
    end
    
    self:updateGUI()
end

function Game:drawCircle(range, screenPos)
    self.hoverCircle = flower.Circle(range, 100)
    self.hoverCircle:setPos(screenPos[1], screenPos[2])
    self.hoverCircle:setColor(0.6, 0.4, 0.4, 0.1)
    self.hoverCircle:setLayer(self.layer)
end

-- Returns the selected tower
function Game:getSelectedTower()
    return self.towerSelected
end

-- Event callback for mouse touch input
--TODO: clean this up
function Game:onTouchDown(pos, inputType)
    if self:stopped() then
        flower.closeScene({animation = "fade"})
    end
    
    local tile = self.map:getTile(pos)
    
    -- The user clicked a tile that we want to ignore
    if tile == 0 then
        return
    end
    
    if tile == TOWER_TYPES.EMPTY and self.towerSelected ~= nil and inputType == "mouseClick" then
        -- Try to place new tower down
        if self.currentCash >= self.towerSelected.type.cost then
            
            -- Decrease cash amount
            self.currentCash = self.currentCash - self.towerSelected.type.cost
            
            -- Place tower on map
            self.map:setTile(pos, self.towerSelected.type.id)
            self.towers[Tower.serialize_pos(pos)] = Tower(self.towerSelected.type, pos)
            
            self:updateGUI()
        else
            -- TODO: alert for insufficient funds
        end
    elseif tile ~= TOWER_TYPES.EMPTY and tile ~= TOWER_TYPES.ENEMY then
        local key = Tower.serialize_pos(pos)
        local tower = self.towers[key]
        -- Select already placed tower
        -- TODO: upgrade and sell options appear
        if inputType == "mouseClick" then
            if self.towerSelected == tower then
                self:selectTower(nil)
                self.map:unselectTile()
            else
                self:selectTower(tower)
                self.map:selectTile(pos)
                self.towerSelected = nil
            end
        elseif inputType == "mouseRightClick" then
            -- Sell the tower
            self.currentCash = self.currentCash + tower.type.cost / 2
            self.map:clearTile(pos)
            self.towers[key] = nil
        end        
    end
end

function Game:onMouseMove(pos)
    -- TODO: use mouse move event to show the user where the tower will be placed on the grid
    -- and show the radius of the tower being placed
    self.cursorPos = self.map:gridToScreenSpace(pos)
    if self.hoverCircle and not self.map:isTileSelected() then
        self.hoverCircle:setPos(self.cursorPos[1], self.cursorPos[2])
    end
end