local map = {}
map.width = 10
map.height = 35

map.tiles = "assets/grid.sav"
map.waves = {
    {enemies = {"NORMAL"}, spawnRate = 0.2, length = 100},
    {enemies = {"NORMAL", "FAST"}, spawnRate = 0.1, length = 200},
    {enemies = {"NORMAL", "FAST", "HEAVY"}, spawnRate = 0.08, length = 300},
}

return map