require "assets/towers/towerTypes"

local towers = {}

local YellowTower = {}
YellowTower.id = TOWER_TYPES.YELLOW
YellowTower.name = "Yellow Tower"
YellowTower.cost = 200
YellowTower.damage = 100
YellowTower.range = 5
YellowTower.speed = 50
YellowTower.description = "Yellow Description"
YellowTower.texture = "yellow_tower.png"
towers[TOWER_TYPES.YELLOW] = YellowTower

local RedTower = {}
RedTower.id = TOWER_TYPES.RED
RedTower.name = "Red Tower"
RedTower.cost = 150
RedTower.damage = 20
RedTower.range = 3
RedTower.speed = 30
RedTower.description = "Red Description"
RedTower.texture = "red_tower.png"
towers[TOWER_TYPES.RED] = RedTower


local GreenTower = {}
GreenTower.id = TOWER_TYPES.GREEN
GreenTower.name = "Green Tower"
GreenTower.cost = 100
GreenTower.damage = 5
GreenTower.range = 2
GreenTower.speed = 2
GreenTower.description = "Green Description"
GreenTower.texture = "green_tower.png"
towers[TOWER_TYPES.GREEN] = GreenTower

local BlueTower = {}
BlueTower.id = TOWER_TYPES.BLUE
BlueTower.name = "Blue Tower"
BlueTower.cost = 100
BlueTower.damage = 25
BlueTower.range = 1
BlueTower.speed = 15
BlueTower.description = "Blue Description"
BlueTower.texture = "blue_tower.png"
towers[TOWER_TYPES.BLUE] = BlueTower

return towers