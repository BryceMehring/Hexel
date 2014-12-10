require "assets/tileTypes"

local towers = {}

local SlowTower = {}
SlowTower.id = TILE_TYPES.SLOW1
SlowTower.name = "Slow Tower"
SlowTower.cost = 200
SlowTower.damage = {
    func = "slow",
    params = {
        slowAmount = 0.4,
        time = 5,
    }
}
SlowTower.range = 5
SlowTower.speed = 100
SlowTower.description = ""
SlowTower.texture = "slow1_tower.png"
towers[SlowTower.id] = SlowTower

local BasicTower = {}
BasicTower.id = TILE_TYPES.BASIC1
BasicTower.name = "Basic Tower"
BasicTower.cost = 150
BasicTower.damage = {
    func = "damage",
    params = { damage = 20 }
}
BasicTower.range = 3
BasicTower.speed = 30
BasicTower.description = ""
BasicTower.texture = "basic1_tower.png"
towers[BasicTower.id] = BasicTower

local PoisonTower = {}
PoisonTower.id = TILE_TYPES.POSION1
PoisonTower.name = "Poison Tower"
PoisonTower.cost = 100
PoisonTower.damage = {
    func = "damage",
    params = { damage = 25 }
}
PoisonTower.range = 1
PoisonTower.speed = 15
PoisonTower.description = ""
PoisonTower.texture = "poison1_tower.png"
towers[PoisonTower.id] = PoisonTower

local TowerFire1 = {}
TowerFire1.id = TILE_TYPES.FIRE1
TowerFire1.name = "Fire Tower"
TowerFire1.cost = 120
TowerFire1.damage = {
    func = "damage",
    params = { damage = 25 }
    }
TowerFire1.range = 9
TowerFire1.speed = 35
TowerFire1.description = ""
TowerFire1.texture = "fire1_tower.png"
towers[TowerFire1.id] = TowerFire1

return towers