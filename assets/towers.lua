local YELLOW = 1
local RED = 2
local GREEN = 3
local BLUE = 4
local EMPTY = 5
local ENEMY = 6
local VOID = 7

local towers = {}

local YellowTower = {}
YellowTower.id = YELLOW
YellowTower.name = "Yellow Tower"
YellowTower.cost = 50
YellowTower.damage = 100
YellowTower.range = 5
YellowTower.speed = 50
YellowTower.description = "Yellow Description"
YellowTower.texture = "yellow_tower.png"
towers[YELLOW] = YellowTower

local RedTower = {}
RedTower.id = RED
RedTower.name = "Red Tower"
RedTower.cost = 50
RedTower.damage = 20
RedTower.range = 3
RedTower.speed = 10
RedTower.description = "Red Description"
RedTower.texture = "red_tower.png"
towers[RED] = RedTower


local GreenTower = {}
GreenTower.id = GREEN
GreenTower.name = "Green Tower"
GreenTower.cost = 100
GreenTower.damage = 5
GreenTower.range = 2
GreenTower.speed = 2
GreenTower.description = "Green Description"
GreenTower.texture = "green_tower.png"
towers[GREEN] = GreenTower

local BlueTower = {}
BlueTower.id = BLUE
BlueTower.name = "Blue Tower"
BlueTower.cost = 100
BlueTower.damage = 30
BlueTower.range = 1
BlueTower.speed = 15
BlueTower.description = "Blue Description"
BlueTower.texture = "blue_tower.png"
towers[BLUE] = BlueTower

return towers