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
require "source/utilities/circularQueue"

local Towers = require "assets/towers/towers"
local JSON = require "source/libraries/JSON"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

Client = flower.class()
--Add 3% to the interest rate each turn
Client.INTEREST_INCREMENT = 3 

function Client:init(t)
    -- TODO: pass is variables instead of hardcoding them
    self.texture = "hex-tiles.png"
    self.width = 50
    self.height = 100
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
    
    self.chatQueue = CircularQueue(12)
    self.chatQueue:push("Hello")
    
    self.map = nil
    
    
    self.currentLives = 20
    self.currentCash = 5000
    self.currentInterest = 0
    
    self.towers = {}
    self.attacks = {}
    self.enemies = {}
    
    self.difficulty = 1
    self.currentWave = Wave {
        number = 0, 
        difficulty = self.difficulty, 
        --layer = self.layer, 
        --map = self.map
    }
    
    self.nfe = t.nfe
    local connected, networkError = self.nfe:isConnected()
    if not connected then
        self:showEndGameMessage("Cannot connect to server: " .. networkError)
    end
    
    self:sendConnectMessage()
end

function Client:sendConnectMessage()
    local data = {connected=true}
    jsonString = JSON:encode(data)
    self.nfe:talker(jsonString)
end

-- This function is used by the guiUtilities file to generate
-- the status field in the UI
function Client:generateItemInfo()
    return self.towerSelected and self.towerSelected:getDescription() or ""
end

function Client:generateStatus()
   return "Wave: " .. self.currentWave.number ..
          "  Lives: " .. self.currentLives ..
          "\nCash: " .. self.currentCash ..
          "  Interest: " .. self.currentInterest .. "%"
end


function Client:getPopupPos()
    return {flower.viewWidth / 5, flower.viewHeight / 2}
end 

function Client:getPopupSize()
    return {flower.viewWidth / 2, 100}
end

------------------------------------------------------------------------------------------------------------
-- CHANGE
------------------------------------------------------------------------------------------------------------
-- Initializes the game to run by turning on the spawning of enemies
function Client:run()    
    self.enemies = {}
    self.enemiesToSpawn = {}
    
    self:paused(true)
    
    flower.Executors.callLoop(self.loop, self)
end


-- Main game loop which updates all of the entities in the game
function Client:loop()
    ------------------------------------------------------------------
    -- Get Network updates
    ------------------------------------------------------------------
    local data = self.nfe:listener()
    if data then
        self:handleData(data)
    elseif not self.nfe:isConnected() then
        self:showEndGameMessage("Disconnected from server")
    end
    
    for i, attackData in ipairs(self.attacks) do
        local v1 = attackData[1]
        local v2 = attackData[2]
        local attack = Line({{x=v1[1], y=v1[2]}, {x=v2[1], y=v2[2]}})
        attack:setColor(1,1,1,1)
        attack:setLayer(self.layer)
        attack:setVisible(true)
        flower.Executors.callLaterFrame(0.1, function()
            attack:setLayer(nil)
            attack:setVisible(false)
        end)
    end
    self.attacks = {}
    
    self:updateGUI()
    
    return self:stopped()
end

function Client:handleData(text)
    local data = JSON:decode(text)

    if data.message ~= nil then
        print("message received")
        self:submitText(data.message, true)
    end

    if data.game_data ~= nil then
        --print("game data received")
        for i = #self.enemies, 1, -1 do
            self.enemies[i]:remove()
            table.remove(self.enemies, i)
        end
        for i = #self.towers, 1, -1 do
            table.remove(self.towers, i)
        end
        
        --for i, attackData in ipairs(data.game_data.attacks) do
        ---    print(attackData[1], attackData[2])
        --end
        self.currentLives      = data.game_data.currentLives
        self.currentCash       = data.game_data.currentCash
        self.currentInterest   = data.game_data.currentInterest
        self.towers            = {}
        self.enemies           = {}
        self.attacks           = data.game_data.attacks
        self.difficulty        = data.game_data.difficulty
        self.currentWave       = data.game_data.currentWave
        
        for key, tower in pairs(data.game_data.towers) do
            self.towers[key] = Tower(tower.type, tower.pos)
            self.towers[key].level = tower.level
            self.towers[key].killCount = tower.killCount
        end
        
        self.map:resetTowers(self.towers)
        for i, enemy in ipairs(data.game_data.enemies) do
            self.enemies[i] = Enemy {
                type = enemy.type
            }
            self.enemies[i].stats = enemy.stats
            self.enemies[i].dead = enemy.dead
            self.enemies[i].dying = enemy.dying
            self.enemies[i]:renderEnemy(enemy.position, self.layer, self.map)
            self.enemies[i]:updateHealthBar()
        end
            
    end

    if data.map_data ~= nil then
        print("map data received")
        print(text)
        self.map = Map {
            file = data.map_data.file,
            texture = data.map_data.texture,
            width = data.map_data.width,
            height = data.map_data.height,
            tileWidth = self.tileWidth,
            tileHeight = self.tileHeight,
            radius = self.radius,
            layer = self.layer,
        }
    end

    if data.pause ~= nil then
        print("pause data received")
        local bool
        if data.pause == "true" then
            bool = true
        elseif data.pause == "false" then
            bool = false
        end
        self:paused(bool, false)
    end

    if data.display ~= nil then
        print("display data received")
        local msgBox = generateMsgBox(
            self:getPopupPos(), 
            self:getPopupSize(), 
            display.message,
            self.popupView)
    
        msgBox:showPopup()
        flower.Executors.callLaterTime(display.duration, function()
            msgBox:hidePopup()
            self.popupView:removeChild(msgBox)
        end)
    end
end

-- Pauses the game if p is true, unpauses the game if p is false
-- If p is nil, paused() return true if the game is paused
function Client:paused(p, sendMessage)
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
        
        if sendMessage == nil or sendMessage == true then
            self:sendPauseMessage(p)
        end
    else
        return self.isPaused
    end
end

-- Stops the game if s is true
-- Returns true if the game if s is nil
function Client:stopped(s)
    if s ~= nil then
        
        if s == true then
            self.soundManager:stop()
            if self.timers then
                for k, timer in pairs(self.timers) do
                    flower.Executors.cancel(timer)
                end
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

function Client:updateGUI()
    updateStatusText(self:generateStatus())
    updateItemText(self:generateItemInfo())
end

-- not self.map:isTileSelected() mouse has the circle
-- Updates the current tower selected
function Client:selectTower(tower)
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

function Client:drawCircle(range, screenPos)
    self.hoverCircle = flower.Circle(range, 100)
    self.hoverCircle:setPos(screenPos[1], screenPos[2])
    self.hoverCircle:setColor(0.6, 0.4, 0.4, 0.1)
    self.hoverCircle:setLayer(self.layer)
end

-- Returns the selected tower
function Client:getSelectedTower()
    return self.towerSelected
end

-- Event callback for mouse touch input
--TODO: clean this up
function Client:onTouchDown(pos, inputType)
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
            
            ----------------------------------------------------
            -- Send tower place command
            ----------------------------------------------------
            self:sendTowerPlaceMessage(pos, self.towerSelected.type)
            
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
            ------------------------------------------------------
            -- Send tower sell command
            ------------------------------------------------------
            self:sendTowerSellMessage(pos)
        end        
    end
end

function Client:onMouseMove(pos)
    -- TODO: use mouse move event to show the user where the tower will be placed on the grid
    -- and show the radius of the tower being placed
    self.cursorPos = self.map:gridToScreenSpace(pos)
    if self.hoverCircle and not self.map:isTileSelected() then
        self.hoverCircle:setPos(self.cursorPos[1], self.cursorPos[2])
    end
end

function Client:sendTowerPlaceMessage(pos, type)
    local data = {tower_place={pos=pos, type=type}}
    jsonString = JSON:encode(data)
    self.nfe:talker(jsonString)
end

function Client:sendTowerSellMessage(pos)
    local data = {tower_sell={pos=pos}}
    jsonString = JSON:encode(data)
    self.nfe:talker(jsonString)
end

function Client:sendPauseMessage(p)
    local data = {}
    if p then
        data = {pause="true"}
    else
        data = {pause="false"}
    end
    jsonString = JSON:encode(data)
    self.nfe:talker(jsonString)
end