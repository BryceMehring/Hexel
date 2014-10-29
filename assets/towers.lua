local YELLOW = 1
local RED = 2
local GREEN = 3
local BLUE = 4
local EMPTY = 5
local ENEMY = 6
local VOID = 7

Towers = {}

local YellowTower = {}
YellowTower.id = YELLOW
YellowTower.name = "Yellow Tower"
YellowTower.cost = 50
YellowTower.damage = 10
YellowTower.range = 3
YellowTower.description = "???"
YellowTower.texture = "yellow_tower.png"
Towers[YELLOW] = YellowTower

local RedTower = {}
RedTower.id = RED
RedTower.name = "Red Tower"
RedTower.cost = 50
RedTower.damage = 7
RedTower.range = 5
RedTower.description = "???"
RedTower.texture = "red_tower.png"
Towers[RED] = RedTower


local GreenTower = {}
GreenTower.id = GREEN
GreenTower.name = "Green Tower"
GreenTower.cost = 100
GreenTower.damage = 10
GreenTower.range = 7
GreenTower.description = "???"
GreenTower.texture = "green_tower.png"
Towers[GREEN] = GreenTower

local BlueTower = {}
BlueTower.id = BLUE
BlueTower.name = "Blue Tower"
BlueTower.cost = 100
BlueTower.damage = 35
BlueTower.range = 3
BlueTower.description = "???"
BlueTower.texture = "blue_tower.png"
Towers[BLUE] = BlueTower

return Towers