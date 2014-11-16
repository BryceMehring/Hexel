local map = {}
map.width = 10
map.height = 35

map.tiles = "assets/grid.sav"
map.waves = {
    {enemies = {TOWER_TYPES.RED, TOWER_TYPES.YELLOW, TOWER_TYPES.GREEN}, spawnRate = 0.5, length = 100},
    {enemies = {TOWER_TYPES.RED, TOWER_TYPES.GREEN}, spawnRate = 0.4, length = 200},
    {enemies = {TOWER_TYPES.RED}, spawnRate = 0.3, length = 300},
}

return map