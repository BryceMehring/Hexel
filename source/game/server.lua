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
    
    for key, tower in pairs(self.towers) do
        tower:fire(self.enemies)
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
    
    --COMMAND NEEDED: Send end of wave msg
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
    print("Number of Enemies: " .. #self.enemiesToSpawn .. "  " .. "SpawnRate = " .. spawnRate .. " seconds per enemy")
    local spawnTimer = flower.Executors.callLoopTime(spawnRate, self.spawnLoop, self)
    self.timers = {
        spawnTimer = spawnTimer,
    }
    
    self.timers.spawnTimer:start()
end

-- COMMAND NEEDED: PLAYERS LOSE LIFE!
-- Looses a life and ends the game if the lives count reaches 0
function Game:loseLife()
    self.currentLives = self.currentLives - 1
    if self.currentLives <= 0 then
        self:showEndGameMessage("Game Over!")
    end
end

-- Shows a message box with a message just before ending the game
function Game:showEndGameMessage(msg)
    --COMMAND NEEDED: SEND END OF GAME NOTIFICATION
    local msgBox = generateMsgBox(self:getPopupPos(), self:getPopupSize(), msg, self.popupView)
    msgBox:showPopup()
    flower.Executors.callLaterTime(3, function()
        msgBox:hidePopup()
        self.popupView:removeChild(msgBox)
    end)
    self:stopped(true)
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
