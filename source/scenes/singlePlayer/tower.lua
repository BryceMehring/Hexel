local flower = require "source/libraries/flower"
local class = flower.class

local Towers = require "assets/towers"

-- module
local M = {}

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
        temp_targets = {}
        flower.table.deepCopy(self.targets, temp_targets)
        for key, pos in pairs(temp_targets) do
            local temp_pos = {}
            
            temp_pos[1] = pos[1]
            temp_pos[2] = pos[2] + 1
            self:add_target(temp_pos)
            
            temp_pos[1] = pos[1]
            temp_pos[2] = pos[2] + 2
            self:add_target(temp_pos)
            
            temp_pos[1] = pos[1]
            temp_pos[2] = pos[2] - 1
            self:add_target(temp_pos)
            
            temp_pos[1] = pos[1]
            temp_pos[2] = pos[2] - 2
            self:add_target(temp_pos)
            
            if pos[2]%2 == 0 then
                temp_pos[1] = pos[1] + 1
            else
                temp_pos[1] = pos[1] - 1
            end
            temp_pos[2] = pos[2] - 1
            self:add_target(temp_pos)
            
            if pos[2]%2 == 0 then
                temp_pos[1] = pos[1] + 1
            else
                temp_pos[1] = pos[1] - 1
            end
            temp_pos[2] = pos[2] + 1
            self:add_target(temp_pos)
        end
    end
end

function Tower:add_target(pos)
    local key = Tower.serialize_pos(pos)
    if self.targets[key] == nil then
        self.targets[key] = {}
        flower.table.copy(pos, self.targets[key])
    end
end

function Tower:upgrade(type)
    -- TODO: Change stats
    self.level = self.level + 1
end

return M
