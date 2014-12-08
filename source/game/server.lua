--------------------------------------------------------------------------------
-- server.lua - Defines a game which(for now) manages the game logic for a single player game
--------------------------------------------------------------------------------

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
local JSON = require "source/libraries/JSON"

-- import
local flower = flower
local math = math
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local ipairs = ipairs

Server = flower.class()
--Add 3% to the interest rate each turn
Server.INTEREST_INCREMENT = 3 

function Server:init(t)
    -- TODO: pass is variables instead of hardcoding them
    self.texture = "hex-tiles.png"
    self.tileWidth = 128
    self.tileHeight = 111
    self.width = 50
    self.height = 100
    self.radius = 24
    self.default_tile = 0
    self.direction = 1
    self.layer = t.layer
    self.mapFile = t.mapFile
    
    self.view = t.view
    self.popupView = t.popupView
    
    -- BEGIN Necessary Client Data
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
    self.chatQueue = CircularQueue(12)
    self.chatQueue:push("Hello")
    
    self.nfe = t.nfe
    local connected, networkError = self.nfe:isConnected()
    if not connected then
        return
    end 
end

-- Initializes the game to run by turning on the spawning of enemies
function Server:run()    
    self.enemies = {}
    self.enemiesToSpawn = {}
    
    self:paused(true)
    
    self:waitForClient()
    self:sendMapInfo()
    
    flower.Executors.callLoop(self.loop, self)
end

function Server:waitForClient()
    local data = nil
    while data == nil do
        local text = self.nfe:listener()
        data = JSON:decode(text)
        if data.connected == true then
            break
        end
    end
    self:paused(false)
    print("Client Found")
end

function Server:sendMapInfo()
    local object = {}
    object.map_data = {file = self.mapFile, texture = self.texture, width = self.width, height = self.height}
    local temp = JSON:encode(object)
    self.nfe:talker(temp)
end

-- Main game loop which updates all of the entities in the game
function Server:loop()
    -- DO FRAME
    if not self:paused() then
        if #self.enemiesToSpawn == 0 and #self.enemies == 0 then
            if self.currentWave.number > 0 then
                self.currentInterest = self.currentInterest + Server.INTEREST_INCREMENT
                self.currentCash = math.floor(self.currentCash * (1+self.currentInterest/100))
            end
            
            -- increment to the next wave
            print("about to setup")
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
        
        -- Fire lasers
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
--        for key, tower in pairs(self.towers) do
--            tower:fire(self.enemies)
--        end
    end
    
    -- CONSUME INPUTS
    local data = self.nfe:listener()
    if data then
        self:handleData(data)
    elseif not self.nfe:isConnected() then
--        self:showEndGameMessage("Disconnected from server")
        return
    end
    
    -- SEND STATE TO CLIENTS
    local jsonEnemies = {}
    for i, enemy in ipairs(self.enemies) do
        jsonEnemies[i] = enemy:getJSONData()
    end
    local jsonTowers = {}
    for key, tower in pairs(self.towers) do
        jsonTowers[key] = tower:getJSONData()
    end
    local object = {}
    object.game_data = {currentLives=self.currentLives, currentCash=self.currentCash, currentInterest=self.currentInterest, towers=jsonTowers, attacks=self.attacks, difficulty=self.difficulty, currentWave=self.currentWave, enemies=jsonEnemies}
    local temp = JSON:encode(object)
    self.nfe:talker(temp)
    --COMMAND NEEDED: Send enemies map towers etc
    
    return self:stopped() -- Needed?
end

function Server:setupNextWave()
    self:paused(true)
    --SEND PAUSED COMMAND (3 seconds, "Wave: " .. self.currentWave.number)
    
    self.currentWave:increment()
    
    -- TODO: add an option so that the game keeps on going, like a survival mode, issue #51
    if self.currentWave:currentNumber() > 50 then
        -- TODO: command needed
        --self:showEndGameMessage("You've Won the main game")
    end
    
    self.enemiesKilled = 0
    self.spawnedEnemies = 0
    self.enemies = {}
    
    self.currentWave:setup()
    self.enemiesToSpawn = self.currentWave:getEnemies()
    
    --self:updateGUI()
    
    --COMMAND NEEDED: Send end of wave msg
--    local msgBox = generateMsgBox(
--        self:getPopupPos(), 
--        self:getPopupSize(), 
--        "Wave: " .. self.currentWave.number, 
--        self.popupView)
    
--    msgBox:showPopup()
-- TODO: message command here
    flower.Executors.callLaterTime(3, function()
        --msgBox:hidePopup()
        --self.popupView:removeChild(msgBox)
        self:startSpawnLoop()
        self:paused(false)
    end)
end

function Server:spawnLoop()
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

function Server:startSpawnLoop()    
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
function Server:loseLife()
    self.currentLives = self.currentLives - 1
    if self.currentLives <= 0 then
        self:showEndGameMessage("Game Over!")
    end
end

-- Shows a message box with a message just before ending the game
function Server:showEndGameMessage(msg)
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
function Server:paused(p)
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
        --updatePauseButton(not p, self.currentWave.number)
    else
        return self.isPaused
    end
end

-- Stops the game if s is true
-- Returns true if the game if s is nil
function Server:stopped(s)
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

function Server:attemptToPlaceTower(tower)
--    tower.coordinate : pos
--    tower.type : towerSelected.type
    local tile = self.map:getTile(tower.pos)
    print(tile)
    
    -- The user clicked a tile that we want to ignore
    if tile == 0 then
        return
    end
    
    print("we made it")
    if tile == TOWER_TYPES.EMPTY then
        print("farther")
        -- Try to place new tower down
        if self.currentCash >= tower.type.cost then
            print("almost there")
            -- Decrease cash amount
            self.currentCash = self.currentCash - tower.type.cost
            print(self.currentCash)
            -- Place tower on map
            print(tower.type.id)
            self.map:setTile(tower.pos, tower.type.id)
            self.towers[Tower.serialize_pos(tower.pos)] = Tower(tower.type, tower.pos)
        else
            -- TODO: alert for insufficient funds
        end
    end
    print("goodbye")
end

-- The chat queue needs to be handled similarly to this
--function VersusGame:generateItemInfo()
--   return self.chatQueue:toString()
--end

function Server:handleData(text)
    local data = JSON:decode(text)
    if data.message ~= nil then
        self:submitText(data.message, true)
    end
    if data.tower_place ~= nil then
        print("YO DAWG")
        print(data)
        self:attemptToPlaceTower(data.tower_place)
    end
    
    if data.tower_sell ~= nil then
        --call sell tower function
    end
end

-- TODO: this could be cleaned up, I don't really like using the bool `recieve` here
function Server:submitText(text, recieve)
    
    if not recieve then
        local data = {}
        data.message = text
        jsonString = JSON:encode(data)
        self.nfe:talker(jsonString)
        text = "You: " .. text
    else
        text = "Them: " .. text
    end
    
    self.chatQueue:push(text)
end