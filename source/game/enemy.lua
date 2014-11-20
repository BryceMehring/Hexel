--------------------------------------------------------------------------------
-- enemy.lua - Defines an enemy that has a health bar which follows the path of the map
--------------------------------------------------------------------------------

require "source/utilities/vector"
require "source/game/healthBar"

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
    self.group = flower.Group(t.layer, t.width, t.height)
    self.group:setPos(t.pos[1], t.pos[2])
    
    local rectangle = flower.Rect(t.width, t.height)
    rectangle:setColor(t.color[1], t.color[2], t.color[3], t.color[4])
    
    self.group:addChild(rectangle)
    
    self.healthBar = HealthBar {
        parent = self.group,
        width = t.width,
        height = t.height,
        moveSclTime = 0.08
    }
    
    self.currentPos = 1
    self.speed = t.speed or 5
    self.map = t.map
    self.health = t.health
    self.maxHealth = self.health
    self.score = t.score
end

function Enemy:updateHealthBar()
    self.healthBar:moveScl(self.health / self.maxHealth)
    self.healthBar:setVisible(self.health < self.maxHealth)
end

function Enemy:updatePos()
    local startingPosition = vector{self.group:getPos()}
    local finalPosition = nil
    
    if self.map:getPath() and self.map:getPath()[1] then
        if (self.currentPos == (#self.map:getPath())) then
            return self.END_OF_PATH
        end
        
        finalPosition = vector{self.map:getMOAIGrid():getTileLoc(
            self.map:getPath()[self.currentPos + 1][1],
            self.map:getPath()[self.currentPos + 1][2],
            MOAIGridSpace.TILE_CENTER)}
    
    else
        finalPosition = getPathDestination(self.map:getMOAIGrid(), startingPosition, self.map:getPath())
        
        if finalPosition == nil then
            return self.END_OF_PATH
        end
    end
   
    local positionDiff = finalPosition - startingPosition
    local angle = math.atan2(positionDiff[2], positionDiff[1])
    local velocity = self.speed * vector{math.cos(angle), math.sin(angle)}
    if math.abs(velocity[1]) >= math.abs(positionDiff[1]) and math.abs(velocity[2]) >= math.abs(positionDiff[2]) then
        velocity = positionDiff
        self.currentPos = self.currentPos + 1
    end
    
    local newPosition = velocity + startingPosition
    self.group:setPos(newPosition[1], newPosition[2])
end

function Enemy:update()
    if self.health <= 0 then
        return self.DIED
    end
    
    self:updateHealthBar()
    
    local updateStatus = self:updatePos()
    return updateStatus or self.CONTINUE
end

function Enemy:damage(damage)
    self.health = self.health - damage
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