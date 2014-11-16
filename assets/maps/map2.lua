
local YELLOW = 1
local RED = 2
local GREEN = 3
local BLUE = 4
local EMPTY = 5
local ENEMY = 6
local VOID = 7

local map = {}
map.width = 10
map.height = 35

map.tiles = "grid.sav"
map.waves = {
    {enemies = {RED, YELLOW, GREEN}, spawnRate = 0.5, length = 100},
    {enemies = {RED, GREEN}, spawnRate = 0.4, length = 200},
    {enemies = {RED}, spawnRate = 0.3, length = 300},
}

return map