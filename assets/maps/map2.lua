local map = {}

local YELLOW = 1
local RED = 2
local GREEN = 3
local BLUE = 4
local EMPTY = 5
local ENEMY = 6
local VOID = 7

map.default_tile = EMPTY
map.enemy_tile = ENEMY
map.width = 8
map.height = 35

local tiles = {}
tiles[YELLOW] = {}
tiles[RED] = {}
tiles[GREEN] = {}
tiles[BLUE] = {}
tiles[EMPTY] = {}
tiles[ENEMY] = {
    {2,1},{2,3},{2,5},{2,7},{2,9},{2,11},{2,13},{2,15},{2,17},{2,19},{2,21},{2,23},{2,25},{2,27},{2,28},
    {3,8},{3,9},{3,11},{3,13},{3,15},{3,17},{3,18},{3,20},{3,21},{3,23},{3,25},{3,26},{3,29},{3,30},
    {4,6},{4,7},{4,10},{4,11},{4,13},{4,15},{4,16},{4,18},{4,19},{4,20},{4,26},{4,27},{4,30},{4,31},
    {5,5},{5,6},{5,9},{5,10},{5,16},{5,17},{5,18},{5,21},{5,23},{5,25},{5,28},{5,29},
    {6,7},{6,8},{6,11},{6,13},{6,15},{6,19},{6,21},{6,23},{6,25},{6,27},
    {7,9},{7,11},{7,13},{7,15},{7,17},{7,19},{7,21},{7,23},{7,25},{7,27},{7,29},{7,31},{7,33},{7,35}
}

map.tiles = tiles
map.startPosition = function()
    return tiles[ENEMY][math.random(1, #tiles[ENEMY] - 10)]
end
map.targetPosition = {7, 35}

map.waves = {
    {enemies = {RED, YELLOW, GREEN}, spawnRate = 0.5, length = 30},
    {enemies = {RED, GREEN}, spawnRate = 0.4, length = 40},
    {enemies = {RED}, spawnRate = 0.3, length = 50},
}

return map