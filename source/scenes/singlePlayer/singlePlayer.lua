module(..., package.seeall)

-- import
local flower = flower

local group = nil
local layer = nil
local timer = nil
local grid = nil

function addTouchEventListeners(item)
    item:addEventListener("touchDown", item_onTouchDown)
    item:addEventListener("touchUp", item_onTouchUp)
    item:addEventListener("touchMove", item_onTouchMove)
    item:addEventListener("touchCancel", item_onTouchCancel)
end

function onCreate(e)
    -- TODO: clean this up

    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    local width = 15
    local height = 30
    
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
    
    addTouchEventListeners(grid)

end

function onStart(e)
end

function onStop(e)
end

function item_onTouchDown(e)
    
    local prop = e.prop
    if prop == nil or prop.touchDown and prop.touchIdx ~= e.idx then
        return
    end
    
    -- Convert screen space into hex space
    local x = e.wx
    local y = e.wy
    x, y = layer:wndToWorld(x, y)
    x, y = prop:worldToModel(x, y)
    
    local xCoord, yCoord = grid.grid:locToCoord(x, y)
    xCoord, yCoord = grid.grid:wrapCoord ( xCoord, yCoord )
    
    -- Move to the next color
    grid:setTile(xCoord, yCoord, grid:getTile(xCoord, yCoord) % 5 + 1)
    
    prop.touchDown = true
    prop.touchIdx = e.idx
    prop.touchLastX = e.wx
    prop.touchLastY = e.wy
end

function item_onTouchUp(e)
    
    local prop = e.prop
    if prop == nil or prop.touchDown and prop.touchIdx ~= e.idx then
        return
    end

    prop.touchDown = false
    prop.touchIdx = nil
    prop.touchLastX = nil
    prop.touchLastY = nil
end

function item_onTouchMove(e)
    
    local prop = e.prop
    if prop == nil or not prop.touchDown then
        return
    end
    
    local moveX = e.wx - prop.touchLastX 
    local moveY = e.wy - prop.touchLastY
    prop:addLoc(moveX, moveY, 0)
    prop.touchLastX  = e.wx
    prop.touchLastY = e.wy
end

function item_onTouchCancel(e)
    
    local prop = e.prop
    if prop == nil or not prop.touchDown then
        return
    end
    
    prop.touchDown = false
    prop.touchIdx = nil
    prop.touchLastX = nil
    prop.touchLastY = nil
end
