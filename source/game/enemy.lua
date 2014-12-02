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
    self.stats = flower.table.deepCopy(t.type)

    self.group = flower.Group(t.layer, self.type.size, self.type.size)
    self.group:setPos(t.pos[1], t.pos[2])
    
    local rectangle = flower.Rect(self.type.size, self.type.size)
    rectangle:setColor(self.type.color[1], self.type.color[2], self.type.color[3], self.type.color[4])
    
    self.group:addChild(rectangle)
    
    self.healthBar = HealthBar {
        parent = self.group,
        width = self.type.size,
        height = self.type.size,
        moveSclTime = 0.1
    }
    
    self.currentPos = 1
    self.map = t.map
end

function Enemy:isDead()
    return self.dead or self.dying
end

function Enemy:healthBarCallback()
    self.dead = true
end

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
    if self.moveAction and self.moveAction:isActive() then
        local newSpeed = (self.type.speed * (self.type.speedRecovery)) + self.stats.speed
        self.stats.speed = math.min(newSpeed, self.type.speed)--self.moveSpeed:getPos()
        print(newSpeed .. " " .. self.stats.speed)
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

function Enemy:update()
    if self.dead then
        return self.DIED
    end
    
    self:updateHealthBar()
    
    local updateStatus = self:updatePos()
    return updateStatus or self.CONTINUE
end

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

function Enemy:slow(params)
    local oldSpeed = self.stats.speed
    
    self.stats.speed = math.max(1, self.stats.speed * params.slowAmount)
    
    self.moveSpeed = flower.DisplayObject()
    self.moveSpeed:setPos(self.stats.speed, 0)
    self.moveAction = self.moveSpeed:moveLoc((1 - params.slowAmount) * oldSpeed, 0, 0, params.time, MOAIEaseType.SHARP_EASE_OUT)
end

function Enemy:remove()
    if self.group then
        self.group:setVisible(false)
        self.group:setLayer(nil)
    end
end

function Enemy:get_tile()
    local pos = vector{self.group:getPos()}
    return vector{self.map:getMOAIGrid():locToCoord(pos[1], pos[2])}
end

function Enemy:getCost()
    return self.stats.cost
end

function Enemy:getType()
    return self.type
end

function Enemy:isA(otherType)
    return self.type == ENEMY_TYPES[otherType]
end