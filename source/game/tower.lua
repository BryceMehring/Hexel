--------------------------------------------------------------------------------
-- tower.lua - Defines a tower which has the ability to fire upon enemies
--------------------------------------------------------------------------------

local class = flower.class
require "source/gridNeighbors"
require "source/utilities/vector"
require "source/sound/sound"

local soundManager = SoundManager {
    volume = 0.1,
}
local fireSound = soundManager:addSound("assets/sounds/laser2.wav")

Tower = class()

function Tower.serialize_pos(pos)
    return table.concat(pos, " ")
end

---
-- The constructor.
function Tower:init(towerType, pos)
    self.type = towerType
    self.pos = pos
    self.targets = {}
    self.level = 1
    self.killCount = 0
    self.fire_tick = self.type.speed
    
    self.damageFunct = Enemy[self.type.damage.func]
    assert(self.damageFunct, "Invalid damage function")
    
    if self.pos then
        self:calculate_targets()
    end
end

function Tower:getDescription()
    return self.type.name ..
        "\nCost:" .. self.type.cost .. "  Type: " .. self.type.damage.func .. "\n" ..
        (self.type.damage.params.damage and ("Damage: " .. self.type.damage.params.damage) or ("Slow Amount: " .. self.type.damage.params.slowAmount)) ..
        "\nRange:" .. self.type.range .. "  Attack Rate: " .. self.type.speed ..
        ((self.killCount > 0 and (" \nKills: " .. self.killCount)) or "")
end

function Tower:fire(enemies)
    if self.fire_tick == self.type.speed then
        for i=#enemies,1, -1 do
            local tile = enemies[i]:get_tile()
            if self.targets[Tower.serialize_pos(tile)] ~= nil and not enemies[i]:isDead() then
                soundManager:play(fireSound)
                self.fire_tick = 0
                
                local isDead = self.damageFunct(enemies[i], self.type.damage.params)
                if isDead then
                    self.killCount = self.killCount + 1
                end
                
                return i
            end
        end
    else
        self.fire_tick = self.fire_tick + 1
    end
end

function Tower:calculate_targets()
    self.targets[Tower.serialize_pos(self.pos)] = self.pos
    for i=1, self.type.range do
        local temp_targets = flower.table.copy(self.targets)
        for key, pos in pairs(temp_targets) do
            local neighbors = getHexNeighbors(pos)
            for i, dir in ipairs(neighbors) do
                local newPos = pos + dir
                self:add_target(newPos)
            end
        end
    end
end

function Tower:add_target(pos)
    local key = Tower.serialize_pos(pos)
    if self.targets[key] == nil then
        self.targets[key] = vector(pos)
    end
end

function Tower:upgrade(type)
    -- TODO: Change stats
    self.level = self.level + 1
end