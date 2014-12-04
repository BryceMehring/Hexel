--------------------------------------------------------------------------------
-- wave.lua - Creates many enemies for the current wave
--------------------------------------------------------------------------------

require "source/utilities/extensions/math"
require "assets/enemies/enemyTypes"
require "source/utilities/vector"
require "source/game/enemy"

local math = math

Wave = flower.class()

function Wave:init(t)
    self.number = t.number or 1
    self.difficulty = t.difficulty or 1
end

function Wave:setup()
    self.time = 9 + self.number *.75
    self.powerSpawnRate = 25 + .50 * self.number * math.log10(self.number)
    self.totalPower = self.powerSpawnRate * self.time
end

function Wave:getEnemies()
    if not self.totalPower then
        self.setup()
    end
    
    local enemyTypes = getTypesAllowed(self.number)
    local enemies = {}
    
    for key, enemyType in pairs(enemyTypes) do
        local rankedEnemyType = flower.table.deepCopy(ENEMY_TYPES[enemyType])
        rankedEnemyType.health = rankedEnemyType.health * ((self.number * 0.02) + 1.0)
        local costPerEnemy = rankedEnemyType.cost
        
        local maxPowerThisType = self.totalPower / #enemyTypes
        for i= 0 , maxPowerThisType, costPerEnemy do
            local newEnemy = Enemy {
                type = rankedEnemyType
            }
            table.insert(enemies, newEnemy)
        end
        
    end
    
    math.shuffle(enemies)
    return enemies
end

function getTypesAllowed(waveNum)
    if waveNum >= 50 then
        return {"NORMAL", "FAST", "HEAVY", "SUPER"}
    elseif waveNum % 10 == 0 then
        return {"SUPER"}
    elseif waveNum> 35 then
        return {"NORMAL", "FAST", "HEAVY"}
    elseif waveNum> 20 then
        return {"FAST", "HEAVY"}
    elseif waveNum> 10 then
        if waveNum % 2 == 0 then
            return {"NORMAL", "HEAVY"}
        else
            return {"NORMAL", "FAST"}
        end
    elseif waveNum > 4 then
        if waveNum % 2 == 0 then
            return {"HEAVY"}
        else
            return {"FAST"}
        end
    end
    return {"NORMAL"}
end

