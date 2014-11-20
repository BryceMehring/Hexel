local map = {}
map.width = 10
map.height = 35

map.tiles = "assets/grid.sav"
map.waves = {
    {enemies = {{type = "NORMAL", weight = 1}},
                spawnRate = 0.2, length = 100},
    
    {enemies = {{type = "NORMAL", weight = 10},
                {type = "FAST",   weight = 50}},
                spawnRate = 0.1, length = 200},
        
    {enemies = {{type = "NORMAL", weight = 20},
                {type = "FAST", weight = 120},
                {type = "HEAVY", weight = 80}},
                spawnRate = 0.08, length = 300},
        
    {enemies = {{type = "SUPER", weight = 1}},
                spawnRate = 3, length = 20},
}

return map