--------------------------------------------------------------------------------
-- game.lua - Defines a game which(for now) manages the game logic for a single player game
--------------------------------------------------------------------------------
-- TODO: clean this up!

require "source/utilities/vector"
require "source/utilities/extensions/math"
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

local POPUP_SIZE = {flower.viewWidth / 2, 100}
local POPUP_POS = {flower.viewWidth / 5, flower.viewHeight / 2}

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

    self.currentLives = 20
    self.currentCash = 200000
    self.currentInterest = 0
    self.currentScore = 0
    self.layer = t.layer
    self.mapFile = t.mapFile
    
    self.towers = {}
    self.attacks = {}
    
    self.currentWave = 1
    
    self.updateStatus = t.updateStatus
    self.view = t.view
    
    self.soundManager = SoundManager {
       soundDir = "assets/sounds/soundtrack/",
    }
    self.soundManager:randomizedPlay()
    
    self:buildGrid()
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
   return "Wave: " .. self.currentWave ..
          "  Lives: " .. self.currentLives ..
          "\nCash: " .. self.currentCash ..
          "  Interest: " .. self.currentInterest .. "%" ..
          "\nScore: " .. self.currentScore
end

function Game:buildGrid()
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
end

function Game:run()
    
    self.enemies = {}
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
    
    -- Timer controlling when enemies spawn
    local spawnTimer = flower.Executors.callLoopTime(self.map:getWaves()[self.currentWave].spawnRate, function()
        if self.gameOver then
            return
        end
        
        local currentWave = self.map:getWaves()[self.currentWave]
            
        local function pauseIfWaveComplete()
            if self.spawnedEnemies >= currentWave.length then
                self.timers.spawnTimer:pause()
                return true
            end
        end
        
        if pauseIfWaveComplete() then
            return
        end
  
        local randomEnemyType = ENEMY_TYPES[math.randomListElement(currentWave.enemies)]
        
        local newEnemy = Enemy {
            layer = self.layer,
            width = randomEnemyType.size, height = randomEnemyType.size,
            pos = self.map:randomStartingPosition(),
            color = randomEnemyType.color,
            speed = randomEnemyType.speed,
            map = self.map,
            score = 10,
            health = randomEnemyType.health,
        }
        table.insert(self.enemies, newEnemy)
        self.spawnedEnemies = self.spawnedEnemies + 1
    end)

    self.timers = {
        spawnTimer = spawnTimer,
    }
    
    self:paused(false)
    flower.Executors.callLoop(self.loop, self)
end

function Game:updateWave()
    self:paused(true)
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
   
    self.currentWave = (self.currentWave + 1)
    if self.currentWave > #self.map:getWaves() then
        self:showEndGameMessage("You Win!")
        self.gameOver = true
    else
        self.timers.spawnTimer:setSpan(self.map:getWaves()[self.currentWave].spawnRate)
        
        self:updateGUI()
        -- TODO: move this code somewhere else?
        
        local msgBox = generateMsgBox(POPUP_POS, POPUP_SIZE, "Wave: " .. self.currentWave, self.view)
        
        msgBox:showPopup()
        flower.Executors.callLaterTime(3, function()
            msgBox:hidePopup()
            self:paused(false)
        end)
    end
end

function Game:loop()
    
    if self.enemiesKilled == self.map:getWaves()[self.currentWave].length then
        -- increment to the next wave
        self:updateWave()
    end
        
    -- TODO: move the laser into its own class
    for i = #self.attacks, 1, -1 do
        self.attacks[i]:setLayer(nil)
        self.attacks[i]:setVisible(false)
        table.remove(self.attacks, i)
    end
    
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        local enemyStatus = enemy:update()
        if enemyStatus ~= Enemy.CONTINUE then
            self.enemiesKilled = self.enemiesKilled + 1
            if enemyStatus == Enemy.DIED then
                self.currentScore = self.currentScore + enemy.score
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
            local v1 = self.map:gridToWorldSpace(tower.pos)
            local v2 = vector{self.enemies[result].group:getPos()}
            local attack = Line({{x=v1[1], y=v1[2]}, {x=v2[1], y=v2[2]}})
            attack:setColor(1,1,1,1)
            attack:setLayer(self.layer)
            attack:setVisible(true)
            table.insert(self.attacks, #self.attacks, attack)
        end
    end
    
    self:updateGUI()
    
    while self:paused() do
        coroutine.yield()
    end
    
    return self:stopped()
end

function Game:loseLife()
   self.currentLives = self.currentLives - 1
   if self.currentLives <= 0 then
       self:showEndGameMessage("Game Over!")
    end
end

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
        updatePauseButton(not p)
    else
        return self.isPaused
    end
end

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
    self.updateStatus(self:generateStatus())
end

function Game:showEndGameMessage(msg)
    local msgBox = generateMsgBox(POPUP_POS, POPUP_SIZE, msg, self.view)
    msgBox:showPopup()
    self:stopped(true)
end

--TODO: clean this up
function Game:onTouchDown(pos)
    if self:stopped() then
        flower.closeScene({animation = "fade"})
    end
    
    local tile = self.map:getGrid():getTile(pos[1], pos[2])
    -- TODO: highlight map tile
    
    if tile == 5 and self.sideSelect ~= -1 then
        if self.currentCash >= Towers[self.sideSelect].cost then
            self.currentCash = self.currentCash - Towers[self.sideSelect].cost
            self.map:getGrid():setTile(pos[1], pos[2], self.sideSelect)
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