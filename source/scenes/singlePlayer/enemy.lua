
require "source/utilities/vector"

-- import
local flower = flower
local vector = vector
local MOAIGridSpace = MOAIGridSpace
local math = math

enemy = flower.class()

function enemy:init(t)
    self.rectangle = flower.Rect(t.width, t.height)
    self.rectangle:setPos(t.pos[1], t.pos[2])
    self.rectangle:setColor(t.color[1], t.color[2], t.color[3], t.color[4])
    self.rectangle:setLayer(t.layer)
    self.pathIndex = t.pathIndex or 1
    self.currentPos = 1
    self.speed = t.speed or 5
    self.grid = t.grid
    self.map = t.map
    self.path = t.path
end

function enemy:update()
    local startingPosition = vector{self.rectangle:getPos()}
    local finalPosition = nil
    
    if self.map.paths and self.map.paths[self.pathIndex] then
        if (self.currentPos == (#self.map.paths[self.pathIndex])) then
            return false
        end
        
        finalPosition = vector{self.grid:getTileLoc(self.map.paths[self.pathIndex][self.currentPos + 1][1],
                                                          self.map.paths[self.pathIndex][self.currentPos + 1][2],
                                                          MOAIGridSpace.TILE_CENTER)}
    else
        finalPosition = getPathDestination(self.grid, startingPosition, self.path)
        
        if finalPosition == nil then
            return false
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
    self.rectangle:setPos(newPosition[1], newPosition[2])
    
    return true
end

function enemy:remove()
    if self.rectangle then
        self.rectangle:setVisible(false)
        self.rectangle:setLayer(nil)
    end
end