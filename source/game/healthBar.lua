local flower = flower

HealthBar = flower.class()

function HealthBar:init(t)
    self.group = flower.Group(t.layer, t.width, t.height)
    
    local backgroundHealthBar = flower.Rect(t.width, t.height / 4)
    backgroundHealthBar:setPos(0, -t.height / 2)
    backgroundHealthBar:setColor(0, 0, 0, 1) -- TODO: pass in color via ctor
    
    self.healthBar = flower.Rect(t.width, t.height / 4)
    self.healthBar:setPos(0, -t.height / 2)
    self.healthBar:setColor(1, 0, 0, 1) -- TODO: pass in color via ctor
    
    self.group:addChild(backgroundHealthBar)
    self.group:addChild(self.healthBar)
    
    t.parent:addChild(self.group)
    
    self.moveSclTime = t.moveSclTime
    self.moveSclMode = t.moveSclMode or MOAIEaseType.LINEAR
end

function HealthBar:moveScl(percent)
    if not self.oldAction or not self.oldAction:isActive() then
        local currentScl = self.healthBar:getScl()
        local newScl = percent - currentScl
        self.oldAction = self.healthBar:moveScl(newScl, 0, 0, self.moveSclTime, self.moveSclMode)
    end
end

function HealthBar:setVisible(visible)
    self.group:setVisible(visible)
end