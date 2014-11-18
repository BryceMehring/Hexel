
require "source/utilities/vector"

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
    
    local backgroundHealthBar = flower.Rect(t.width, t.height / 4)
    backgroundHealthBar:setPos(0, -t.height / 2)
    backgroundHealthBar:setColor(0, 0, 0, 1)
    
    self.healthBar = flower.Rect(t.width, t.height / 4)
    self.healthBar:setPos(0, -t.height / 2)
    self.healthBar:setColor(1, 0, 0, 1)
    
    self.group:addChild(rectangle)
    self.group:addChild(backgroundHealthBar)
    self.group:addChild(self.healthBar)
    
    self.currentPos = 1
    self.speed = t.speed or 5
    self.map = t.map
    self.health = 100
    self.maxHealth = self.health
    self.score = t.score
end

function Enemy:updateHealthBar()
    local currentScl = self.healthBar:getScl()
    local newScl = (self.health / self.maxHealth) - currentScl
    
    if not self.oldAction or not self.oldAction:isActive() then
        self.oldAction = self.healthBar:moveScl(newScl, 0, 0, 0.08, MOAIEaseType.LINEAR)
    end
end

function Enemy:update()
    local startingPosition = vector{self.group:getPos()}
    local finalPosition = nil
    
    self:updateHealthBar()
    
    if self.health <= 0 then
        return self.DIED
    end
    
    if self.map:GetPath() and self.map:GetPath()[1] then
        if (self.currentPos == (#self.map:GetPath())) then
            return self.END_OF_PATH
        end
        
        finalPosition = vector{self.map:GetMOAIGrid():getTileLoc(
            self.map:GetPath()[self.currentPos + 1][1],
            self.map:GetPath()[self.currentPos + 1][2],
            MOAIGridSpace.TILE_CENTER)}
    
    else
        finalPosition = getPathDestination(self.map:GetMOAIGrid(), startingPosition, self.map:GetPath())
        
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
    
    return self.CONTINUE
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
    return vector{self.map:GetMOAIGrid():locToCoord(pos[1], pos[2])}
end