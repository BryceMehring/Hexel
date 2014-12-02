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
require "source/Networking/NetworkFrameworkEntity"

require "assets/enemies/enemyTypes"

local Towers = require "assets/towers/towers"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

VersusGame = flower.class()

function VersusGame:init(t)
    -- TODO: pass is variables instead of hardcoding them
    self.texture = "hex-tiles.png"
    self.width = 50
    self.height = 100
    self.tileWidth = 128
    self.tileHeight = 111
    self.radius = 24
    self.default_tile = 0
    self.direction = 1

    self.IP = "192.168.0.10"
    
    self.messageBoxText = ""
    self.chatLog = "hello"

    self.currentWave = 1
    
    self.view = t.view
    
    self.nfe = NetworkFrameworkEntity{}
    local connected, networkError = self.nfe:isConnected()
    if not connected then
        self:showEndGameMessage("Cannot connect to server: " .. (networkError or ""))
    end    
end

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function VersusGame:generateItemInfo()
   return self.chatLog
end

function VersusGame:generateStatus()
   return "Welcome to Multiplayer: " .. self.IP .. ""
end

-- TODO: this could be cleaned up, I don't really like using the bool `recieve` here
function VersusGame:submitText(text, recieve)
    
    if not recieve then
        self.nfe:talker(text)
    end
    
    --self.messageBoxText = text
    self.chatLog = self.chatLog .. "\n" .. text..""--self.messageBoxText .. "" 
    --self.generateItemInfo()
    self:updateGUI()
end

function VersusGame:getPopupPos()
    return {flower.viewWidth / 5, flower.viewHeight / 2}
end 

function VersusGame:getPopupSize()
    return {flower.viewWidth / 2, 100}
end

-- Initializes the game to run by turning on the spawning of enemies
function VersusGame:run()
    
    self.enemies = {}
    self.enemiesKilled = 0
    self.spawnedEnemies = 0

    self:paused(false)
    flower.Executors.callLoop(self.loop, self)
end

-- Updates to the next wave while taking account the win condition
-- TODO: clean up win condition
function VersusGame:updateWave()
    self:paused(true)
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
   
    self.currentWave = (self.currentWave + 1)
    if self.currentWave > #self.map:getWaves() then
        self:showEndGameMessage("You Win!")
        self.gameOver = true -- todo: this is really messed up as of right now. Change it!
    else
        self.timers.spawnTimer:setSpan(self.map:getWaves()[self.currentWave].spawnRate)
        
        self:updateGUI()
        
        local msgBox = generateMsgBox(self:getPopupPos(), self:getPopupSize(), "Wave: " .. self.currentWave, self.view)
        
        msgBox:showPopup()
        flower.Executors.callLaterTime(3, function()
            msgBox:hidePopup()
            self:paused(false)
        end)
    end
end

-- Main game loop which updates all of the entities in the game
function VersusGame:loop()
    
    self:updateGUI()
    
    local data = self.nfe:listener()
    if data then
        self:submitText(data, true)
    end
    
    while self:paused() do
        coroutine.yield()
    end
    
    return self:stopped()
end

-- Looses a life and ends the game if the lives count reaches 0
function VersusGame:loseLife()
    self.currentLives = self.currentLives - 1
    if self.currentLives <= 0 then
        self:showEndGameMessage("Game Over!")
    end
end

-- Pauses the game if p is true, unpauses the game if p is false
-- If p is nil, paused() return true if the game is paused
function VersusGame:paused(p)
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

-- Stops the game if s is true
-- Returns true if the game if s is nil
function VersusGame:stopped(s)
    if s ~= nil then
        
        if s == true then
            if self.soundManager then
                self.soundManager:stop()
            end
            if self.timers then
                for k, timer in pairs(self.timers) do
                    flower.Executors.cancel(timer)
                end
                
            end
        end
        
        self.isStopped = s
    else
        return self.isStopped
    end
end

function VersusGame:updateGUI()
    updateStatusText(self:generateStatus())
    updateChatText(self:generateItemInfo())
end

-- Shows a message box with a message just before ending the VersusGame
function VersusGame:showEndGameMessage(msg)
    local msgBox = generateMsgBox(self:getPopupPos(), self:getPopupSize(), msg, self.view)
    msgBox:showPopup()
    self:stopped(true)
end

-- Updates the current tower selected
function VersusGame:selectTower(tower)
    self.towerSelected = tower
    self:updateGUI()
end

-- Returns the selected tower
function VersusGame:getSelectedTower()
    return self.towerSelected
end

-- Event callback for mouse touch input
--TODO: clean this up
function VersusGame:onTouchDown(pos)
    if self:stopped() then
        flower.closeScene({animation = "fade"})
    end
    
    local tile = self.map:getGrid():getTile(pos[1], pos[2])
    
    if tile == TOWER_TYPES.EMPTY and self.towerSelected ~= nil then
        -- Try to place new tower down
        if self.currentCash >= self.towerSelected.type.cost then
            
            -- Decrease cash amount
            self.currentCash = self.currentCash - self.towerSelected.type.cost
            
            -- Place tower on map
            self.map:getGrid():setTile(pos[1], pos[2], self.towerSelected.type.id)
            self.towers[Tower.serialize_pos(pos)] = Tower(self.towerSelected.type, pos)
            
            self:updateGUI()
        else
            -- TODO: alert for insufficient funds
        end
    elseif tile ~= TOWER_TYPES.EMPTY and tile ~= TOWER_TYPES.ENEMY then
        -- Select already placed tower
        -- TODO: upgrade and sell options appear
        self:selectTower(self.towers[Tower.serialize_pos(pos)])
        self.map:selectTile(pos)
    end
    
end