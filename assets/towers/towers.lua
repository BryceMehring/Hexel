require "assets/towers/towerTypes"

local towers = {}

local TowerBasic1 = {}
TowerBasic1.id = TOWER_TYPES.BASIC1
TowerBasic1.name = "Basic Tower"
TowerBasic1.cost = 200
TowerBasic1.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerBasic1.range = 5
TowerBasic1.speed = 40
TowerBasic1.description = "Basic1 Description"
TowerBasic1.texture = "Basic1.png"
towers[TOWER_TYPES.BASIC1] = TowerBasic1

local TowerBasic2 = {}
TowerBasic2.id = TOWER_TYPES.BASIC2
TowerBasic2.name = "Great Basic Tower"
TowerBasic2.cost = 200
TowerBasic2.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerBasic2.range = 6
TowerBasic2.speed = 40
TowerBasic2.description = "Basic2 Description"
TowerBasic2.texture = "Basic2.png"
towers[TOWER_TYPES.BASIC2] = TowerBasic2

local TowerBasic3 = {}
TowerBasic3.id = TOWER_TYPES.BASIC3
TowerBasic3.name = "Mega Basic Tower"
TowerBasic3.cost = 300
TowerBasic3.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerBasic3.range = 8
TowerBasic3.speed = 40
TowerBasic3.description = "Basic3 Description"
TowerBasic3.texture = "Basic3.png"
towers[TOWER_TYPES.BASIC3] = TowerBasic3

local TowerPosion1 = {}
TowerPosion1.id = TOWER_TYPES.POSION1
TowerPosion1.name = "Posion Tower"
TowerPosion1.cost = 120
TowerPosion1.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerPosion1.range = 6
TowerPosion1.speed = 40
TowerPosion1.description = "Posion1 Description"
TowerPosion1.texture = "Posion1.png"
towers[TOWER_TYPES.POSION1] = TowerPosion1

local TowerPosion2 = {}
TowerPosion2.id = TOWER_TYPES.POSION2
TowerPosion2.name = "Great Posion Tower"
TowerPosion2.cost = 120
TowerPosion2.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerPosion2.range = 9
TowerPosion2.speed = 35
TowerPosion2.description = "Posion2 Description"
TowerPosion2.texture = "Posion2.png"
towers[TOWER_TYPES.POSION2] = TowerPosion2

local TowerFire1 = {}
TowerFire1.id = TOWER_TYPES.FIRE1
TowerFire1.name = "Fire Tower"
TowerFire1.cost = 120
TowerFire1.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerFire1.range = 9
TowerFire1.speed = 35
TowerFire1.description = "Fire1 Description"
TowerFire1.texture = "Fire1.png"
towers[TOWER_TYPES.FIRE1] = TowerFire1

local TowerFire2 = {}
TowerFire2.id = TOWER_TYPES.FIRE2
TowerFire2.name = "Grand Fire Tower"
TowerFire2.cost = 120
TowerFire2.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerFire2.range = 9
TowerFire2.speed = 35
TowerFire2.description = "Fire2 Description"
TowerFire2.texture = "Fire2.png"
towers[TOWER_TYPES.FIRE2] = TowerFire2

local TowerSlow1 = {}
TowerSlow1.id = TOWER_TYPES.Slow1
TowerSlow1.name = "Water Tower"
TowerSlow1.cost = 120
TowerSlow1.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerSlow1.range = 9
TowerSlow1.speed = 35
TowerSlow1.description = "Slow1 Description"
TowerSlow1.texture = "Slow1.png"
towers[TOWER_TYPES.SLOW1] = TowerSlow1

local TowerSlow2 = {}
TowerSlow2.id = TOWER_TYPES.Slow2
TowerSlow2.name = "Sleet Tower"
TowerSlow2.cost = 120
TowerSlow2.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerSlow2.range = 9
TowerSlow2.speed = 35
TowerSlow2.description = "Slow2 Description"
TowerSlow2.texture = "Slow2.png"
towers[TOWER_TYPES.SLOW2] = TowerSlow2

local TowerSlow3 = {}
TowerSlow3.id = TOWER_TYPES.Slow3
TowerSlow3.name = "Ice Tower"
TowerSlow3.cost = 120
TowerSlow3.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerSlow3.range = 9
TowerSlow3.speed = 35
TowerSlow3.description = "Slow3 Description"
TowerSlow3.texture = "Slow3.png"
towers[TOWER_TYPES.SLOW3] = TowerSlow3


local YellowTower = {}
YellowTower.id = TOWER_TYPES.YELLOW
YellowTower.name = "Yellow Tower"
YellowTower.cost = 200
YellowTower.damage = {
    func = "slow",
    params = {
        slowAmount = 0.4,
        time = 5,
    }
}
YellowTower.range = 5
YellowTower.speed = 100
YellowTower.description = "Yellow Description"
YellowTower.texture = "yellow_tower.png"
towers[TOWER_TYPES.YELLOW] = YellowTower

local RedTower = {}
RedTower.id = TOWER_TYPES.RED
RedTower.name = "Red Tower"
RedTower.cost = 150
RedTower.damage = {
    func = "damage",
    params = { damage = 20 }
}
RedTower.range = 3
RedTower.speed = 30
RedTower.description = "Red Description"
RedTower.texture = "red_tower.png"
towers[TOWER_TYPES.RED] = RedTower


local GreenTower = {}
GreenTower.id = TOWER_TYPES.GREEN
GreenTower.name = "Green Tower"
GreenTower.cost = 100
GreenTower.damage = {
    func = "damage",
    params = { damage = 5 }
}
GreenTower.range = 2
GreenTower.speed = 2
GreenTower.description = "Green Description"
GreenTower.texture = "green_tower.png"
towers[TOWER_TYPES.GREEN] = GreenTower

local BlueTower = {}
BlueTower.id = TOWER_TYPES.BLUE
BlueTower.name = "Blue Tower"
BlueTower.cost = 100
BlueTower.damage = {
    func = "damage",
    params = { damage = 25 }
}
BlueTower.range = 1
BlueTower.speed = 15
BlueTower.description = "Blue Description"
BlueTower.texture = "blue_tower.png"
towers[TOWER_TYPES.BLUE] = BlueTower

return towers