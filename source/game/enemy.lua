--------------------------------------------------------------------------------
-- enemy.lua - Defines an enemy that has a health bar which follows the path of the map
--------------------------------------------------------------------------------

require "source/utilities/vector"
require "source/game/healthBar"
require "assets/enemies/enemyTypes"

-- import
local flower = flower
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local math = math

Enemy = flower.class()
Enemy.DIED = 1
Enemy.END_OF_PATH = 2
Enemy.CONTINUE = 3

function Enemy:init(t)
    self.type = t.type
    self.stats = flower.table.deepCopy(self.type)
end

--- Places the enemy on the map at a random starting location specified by the map.
-- @param the layer in which the enemy shall spawn on
-- @param the map in which the enemy will spawn on
-- TODO: remove layer as a parameter
function Enemy:spawn(layer, map)
    print("spawning")
    local pos = map:randomStartingPosition()
    
    self.group = flower.Group(layer, self.type.size, self.type.size)
    self.group:setPos(pos[1], pos[2])
    
    self.rectangle = flower.Rect(self.type.size, self.type.size)
    self.rectangle:setColor(self.type.color[1], self.type.color[2], self.type.color[3], self.type.color[4])
    self.group:addChild(self.rectangle)
    
    self.healthBar = HealthBar {
        parent = self.group,
        width = self.type.size,
        height = self.type.size,
        moveSclTime = 0.1
    }
    
    self.currentPos = 1
    self.map = map
end

--- Places the enemy on the map at a random starting location specified by the map.
-- @param the layer in which the enemy shall spawn on
-- @param the map in which the enemy will spawn on
-- TODO: remove layer as a parameter
function Enemy:renderEnemy(pos, layer, map)
    self.group = flower.Group(layer, self.type.size, self.type.size)
    self.group:setPos(pos[1], pos[2])
    
    self.rectangle = flower.Rect(self.type.size, self.type.size)
    self.rectangle:setColor(self.type.color[1], self.type.color[2], self.type.color[3], self.type.color[4])
    self.group:addChild(self.rectangle)
    
    self.healthBar = HealthBar {
        parent = self.group,
        width = self.type.size * self.stats.health * 1.0 / self.type.health,
        height = self.type.size,
        moveSclTime = 0.1
    }
    
    self.map = map
end

--- The enemy will continue to follow its path and update its health bar.
-- @return self.DIED will be returned when the enemy is finished dying. self.CONTINUE will be returned if the enemy shall still be updated
function Enemy:update()
    if self.dead then
        return self.DIED
    end
    
    self:updateHealthBar()
    
    local updateStatus = self:updatePos()
    return updateStatus or self.CONTINUE
end

--- Do damage to the enemy.
-- @param table which has the member `params.damage` which specifies how much of the enemies health is lost
-- @return true if the enemy is dying, else nil
function Enemy:damage(params)
    if self.dying then
        return
    end
    
    self.stats.health = self.stats.health - params.damage
    if self.stats.health <= 0 then
        self.dying = true
        self.stats.health = 0
    end
    
    return self.dying
end

--- Slows down the enemy.
-- @param table which has the following members, 
--      `params.slowAmount` which specifies a percentage of the current speed to slow down to
--      `params.time` which specifies how long the enemy will take to speed up. Note that the enemy can effect the time via `ENEMY_TYPES[type].speedRecovery`
function Enemy:slow(params)
    
    local speedDiff = -self.stats.speed * params.slowAmount
    local easeInTime = math.max(1, self.type.speed / 2)
    
    -- slow down
    self.moveSpeed = flower.DisplayObject()
    self.moveSpeed:setPos(self.stats.speed, 0)
    self.moveAction = self.moveSpeed:moveLoc(speedDiff, 0, 0, easeInTime, MOAIEaseType.SHARP_EASE_IN)
    
    flower.Executors.callLaterTime(easeInTime + 0.1, function()
        -- speed up
        self.moveSpeed = flower.DisplayObject()
        self.moveSpeed:setPos(self.stats.speed, 0)
        self.moveAction = self.moveSpeed:moveLoc((1 - params.slowAmount) * self.type.speed,
            0, 0, params.time * (1 / self.type.speedRecovery), MOAIEaseType.SHARP_EASE_OUT)
    end)
end

--- Removes the enemy from the layer.
function Enemy:remove()
    if self.group then
        self.group:setVisible(false)
        self.group:setLayer(nil)
        self.group = nil
    end
end

--- Retreives the current tile the enemy is currently on.
-- @return the current tile as a vector in grid space
function Enemy:get_tile()
    local pos = vector{self.group:getPos()}
    return vector{self.map:getMOAIGrid():locToCoord(pos[1], pos[2])}
end

--- Retreives the enemy cost.
-- Onces the enemy dies, the user will recieve this amount of money for thier effort.
-- @return the enemy cost
function Enemy:getCost()
    return self.stats.cost
end

--- Returns the enemy type.
-- @return a table which describes the type enemy
function Enemy:getType()
    return self.type
end

--- Returns whether or not the enemy is slowed.
-- @return true if the enemy is currently actively slowed, nil otherwise
function Enemy:isSlowed()
    return self.moveAction and self.moveAction:isActive()
end

--- Returns whether or not the enemy is dead.
-- @return true if the enemy is dead or dying, else nil
function Enemy:isDead()
    return self.dead or self.dying
end

------------------- Internal methods, do not call these externally -------------------

function Enemy:updateHealthBar()
    self.healthBar:moveScl(self.stats.health / self.type.health, Enemy.healthBarCallback, self)
    self.healthBar:setVisible(self.stats.health < self.type.health)
end

function Enemy:updatePos()
    if self.dying or self.dead then
        return
    end
    
    local startingPosition = vector{self.group:getPos()}
    local finalPosition = nil
    
    if self.map:getPath() and self.map:getPath()[1] then
        if (self.currentPos == (#self.map:getPath())) then
            return self.END_OF_PATH
        end
        
        finalPosition = self.map:gridToScreenSpace({self.map:getPath()[self.currentPos + 1][1], self.map:getPath()[self.currentPos + 1][2]})
    
    else
        finalPosition = getPathDestination(self.map:getMOAIGrid(), startingPosition, self.map:getPath())
        
        if finalPosition == nil then
            return self.END_OF_PATH
        end
    end
    
    -- Update speed
    if self:isSlowed() then
        local newSpeed = self.moveSpeed:getPos()
        self.stats.speed = math.clamp(newSpeed, self.type.minSpeed, self.type.speed)
        local currentColor = vector(self.type.color)
        currentColor = currentColor * (self.stats.speed / self.type.speed)
        currentColor[4] = 1.0
        self.rectangle:setColor(currentColor:unPack())
    elseif self.moveAction then
        self.moveAction = nil
        self.moveSpeed = nil
    end
   
    local positionDiff = finalPosition - startingPosition
    local angle = math.atan2(positionDiff[2], positionDiff[1])
    local velocity = self.stats.speed * vector{math.cos(angle), math.sin(angle)}
    if math.abs(velocity[1]) >= math.abs(positionDiff[1]) and math.abs(velocity[2]) >= math.abs(positionDiff[2]) then
        velocity = positionDiff
        self.currentPos = self.currentPos + 1
    end
    
    local newPosition = velocity + startingPosition
    self.group:setPos(newPosition[1], newPosition[2])
end

function Enemy:healthBarCallback()
    self.dead = true
end

function Enemy:getJSONData()
    return {type = self.type, stats = self.stats, dying = self.dying, dead = self.dead, position = vector{self.group:getPos()}}
end