local class = flower.class
local Towers = require "assets/towers"
require "source/gridNeighbors"
require "source/utilities/vector"

local fireSound = MOAIUntzSound.new();
fireSound:load("assets/sounds/laser2.wav")
fireSound:setVolume(.1)
fireSound:setLooping(false)

Tower = class()

function Tower.serialize_pos(pos)
    return table.concat(pos, " ")
end

---
-- The constructor.
function Tower:init(type, pos, layer)
    self.type = type
    self.pos = pos
    self.targets = {}
    self.level = 1
    self.range = Towers[type].range
    self.damage = Towers[type].damage
    self.speed = Towers[type].speed
    self.fire_tick = self.speed
    
    self:calculate_targets()
end

function Tower:fire(enemies)
    if self.fire_tick == self.speed then
        for i=#enemies,1,-1 do
            local tile = enemies[i]:get_tile()
            if self.targets[Tower.serialize_pos(tile)] ~= nil then
                fireSound:play()
                enemies[i]:damage(self.damage)
                self.fire_tick = 0
                return i
            end
        end
    else
        self.fire_tick = self.fire_tick + 1
    end
end

function Tower:calculate_targets()
    self.targets[Tower.serialize_pos(self.pos)] = self.pos
    for i=1,self.range do
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