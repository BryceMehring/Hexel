
module(..., package.seeall)

require "source/GuiUtilities"

-- import
local flower = flower
local math = math
local MOAIGridSpace = MOAIGridSpace

-- local variables
local layer = nil

-- Game singleton
Game = {}
Game.texture = "hex-tiles.png"
Game.width = 50
Game.height = 100
Game.tileWidth = 128
Game.tileHeight = 111
Game.radius = 24
Game.default_tile = 0
Game.algorithms = {}
Game.selectedTower = -1
Game.direction = 1
Game.speed = 10

Game.currentCash = 200
Game.currentInterest = "0%"
Game.currentScore = 0

-- This function is used by the GuiUtilities file to generate
-- the status field in the UI
function Game.generateStatus()
   return "Cash: " .. Game.currentCash ..
        "\nInterest: " .. Game.currentInterest ..
        "\nScore: " .. Game.currentScore
end

function Game.buildGrid()
    --params = params or {}
    --Game.texture = params.texture or Game.texture
    Game.width = Map.width or Game.width
    Game.height = Map.height or Game.height
    Game.default_tile = Map.default_tile or Game.default_tile
    --Game.tileWidth = params.tileWidth or Game.tileWidth
    --Game.tileHeight = params.tileHeight or Game.tileHeight
    --Game.radius = params.radius or Game.radius
    
    Game.grid = flower.MapImage(Game.texture,
                                Game.width, 
                                Game.height,
                                Game.tileWidth,
                                Game.tileHeight,
                                Game.radius)
                                  
    Game.grid:setShape(MOAIGridSpace.HEX_SHAPE)
    Game.grid:setLayer(layer)
    
    Game.grid:setRepeat(false, false)
    Game.grid:setPos(0,0)
    
    --print(Game.height, Game.width)
    for i = 1,Game.width do
        for j = 1,Game.height do
            Game.grid.grid:setTile(i, j, Game.default_tile)
        end
    end
    
    for i, data in ipairs(Map.tiles) do
        for j, pos in ipairs(data) do
            Game.grid.grid:setTile(pos[1], pos[2], i)
        end
    end
end

function Game.run()
    Game.my_rectangle = flower.Rect(10,10)
    local x, y = Game.grid.grid:getTileLoc(Map.paths[1][1][1], Map.paths[1][1][2], MOAIGridSpace.TILE_CENTER)
    Game.current_pos = 1
    Game.my_rectangle:setPos(x, y)
    Game.my_rectangle:setColor(1,0,0,1)
    Game.my_rectangle:setLayer(layer)
    
    flower.Executors.callLoop(Game.loop)
end

function Game.loop()
    local m_x, m_y = Game.my_rectangle:getPos()
    if (Game.current_pos == (#Map.paths[1]) and Game.direction > 0) or (Game.current_pos == 1 and Game.direction < 0) then
        Game.direction = -Game.direction
    end
    
    local f_x, f_y = Game.grid.grid:getTileLoc(Map.paths[1][Game.current_pos + Game.direction][1],
                                               Map.paths[1][Game.current_pos + Game.direction][2],
                                               MOAIGridSpace.TILE_CENTER)
                                           
    local angle = math.atan2(f_y - m_y, f_x - m_x)
    local d_x, d_y = Game.speed * math.cos(angle), Game.speed * math.sin(angle)
    if math.abs(d_x) >= math.abs(f_x - m_x) and math.abs(d_y) >= math.abs(f_y - m_y) then
        d_x = f_x - m_x
        d_y = f_y - m_y
        Game.current_pos = (Game.current_pos + Game.direction)
    end
    Game.my_rectangle:setPos(m_x + d_x, m_y + d_y)
    
    return Game.stopped
end

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)

    Game.buildGrid()
    buildUI("SinglePlayer", e.data.view, Game)
end

function onStart(e)
    Game.stopped = false
    Game.run()
end

function onStop(e)
    Game.stopped = true
end