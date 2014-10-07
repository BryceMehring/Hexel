-- TODO: clean this up

module(..., package.seeall)

-- import
local flower = flower

local layer = nil
local grid = nil
local mode = nil
local width = 150
local height = 300

function addTouchEventListeners(item)
    item:addEventListener("touchDown", item_onTouchDown)
    item:addEventListener("touchUp", item_onTouchUp)
    item:addEventListener("touchMove", item_onTouchMove)
    item:addEventListener("touchCancel", item_onTouchCancel)
end

function onCreate(e)
    mode = e.data.params and e.data.params.mode or "default"
    
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    -- Create hex grid
    grid = flower.MapImage("hex-tiles.png", width, height, 128, 111, 16)
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
            grid:setTile(i,j, math.random(1, 6))
        end
    end
    
    grid:setRepeat(true, true)
    grid:setPos(0,50)
    
    -- Make the grid touchable
    addTouchEventListeners(grid)
end

function rippleOut(pos)
    local radius = 0
    local randomTile = math.random(1, 5)
    local directions = {
        {x = 0, y = 1},
        {x = 1, y = 0},
        {x = 0, y =-1},
        {x = -1,y = 0},
    }
    
    local function UpdateTile(newX, newY, newTile)
        newX, newY = grid.grid:wrapCoord ( newX, newY )
        grid:setTile(newX, newY, newTile)
    end
    
    while radius < 10 do
        for i, dir in ipairs(directions) do
            if i == 1 or i == 3 then
                radius = radius + 2
            end
            
            for j=1, radius do
                pos.x = pos.x + dir.x
                pos.y = pos.y + dir.y
                
                flower.Executors.callLaterTime(radius / 50, UpdateTile, pos.x, pos.y, randomTile)
            end
        end
    end
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
    if mode == "pattern" then
        rippleOut({x = xCoord, y = yCoord})
    elseif mode == "default" then
        grid:setTile(xCoord, yCoord, grid:getTile(xCoord, yCoord) % 5 + 1)
    end
    
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
