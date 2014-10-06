module(..., package.seeall)

-- import
local flower = flower

local group = nil
local layer = nil
local timer = nil
local grid = nil

function onCreate(e)
    -- TODO: clean this up

    layer = flower.Layer()
    --layer:setTouchEnabled(true) TODO: get this working
    scene:addChild(layer)
    
    local width = 8
    local height = 15
    
    grid = flower.MapImage("hex-tiles.png", width, height, 128, 111, 32)
    grid:setShape(MOAIGridSpace.HEX_SHAPE)
    grid:setLayer(layer)
    --[[grid:setRows{
        {1, 2, 3, 4, 2, 3, 3, 3},
        {1, 1, 3, 2, 2, 3, 3, 3},
        {4, 1, 1, 2, 2, 3, 3, 3},
        {2, 2, 3, 2, 2, 3, 3, 3},
        {2, 2, 3, 2, 2, 3, 3, 3},
    }]]
    
    -- Randomly fill the grid
    for i=1, width do
        for j=1, height do
            grid:setTile(i,j, math.random(1, 4))
        end
    end
    
    grid:setRepeat(true, true)
    grid:setPos(0,50)

end

function onStart(e)
end

function onStop(e)
end
