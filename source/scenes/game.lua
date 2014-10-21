
module(..., package.seeall)

-- import
local flower = flower

-- local variables
local layer = nil

local game_thread = nil

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

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)

    Game.buildGrid()
end

-- TODO: Make this suck less
local my_rectangle = nil
local current_pos = nil
local speed = 1

function onStart(e)
    my_rectangle = flower.Rect(10,10)
    local x, y = Game.grid.grid:getTileLoc(Map.paths[1][1][1], Map.paths[1][1][2], MOAIGridSpace.TILE_CENTER)
    current_pos = 1
    my_rectangle:setPos(x, y)
    my_rectangle:setColor(1,0,0,1)
    my_rectangle:setLayer(layer)
    flower.Executors.callLoop(Game.gameLoop)
end

function Game.gameLoop()
    local m_x, m_y = my_rectangle:getPos()
    if current_pos ~= #Map.paths[1] then
        local f_x, f_y = Game.grid.grid:getTileLoc(Map.paths[1][current_pos+1][1], Map.paths[1][current_pos+1][2], MOAIGridSpace.TILE_CENTER)
        local d_x = speed * math.cos(math.atan2(f_y-m_y, f_x-m_x))
        local d_y = speed * math.sin(math.atan2(f_y-m_y, f_x-m_x))
        --print(math.atan((f_y-m_y)/(f_x-m_x)), math.sin(math.atan2((f_y-m_y)/(f_x-m_x))))
        --print(m_x,m_y,f_x,f_y,d_x,d_y)
        if math.abs(d_x) >= math.abs(f_x - m_x) and math.abs(d_y) >= math.abs(f_y-m_y) then
            d_x = f_x-m_x
            d_y = f_y-m_y
            current_pos = current_pos + 1
        end
        --print(m_x,m_y,f_x,f_y,d_x,d_y)
        my_rectangle:setPos(m_x+d_x, m_y+d_y)
    end
end

function onStop(e)
    
end