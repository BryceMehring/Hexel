-- TODO: clean this up

module(..., package.seeall)

-- import
local flower = flower

local layer = nil
local grid = nil
local mode = nil
local width = 50
local height = 100

-- TODO: Move this logic elsewhere for finding neighbors
local neighbors = {
    hex = {
        {
           {0, 2},
           {1, 1},
           {1, -1},
           {0, -2},
           {0, -1},
           {0, 1},
        },
        {
            {0, 2},
            {0, 1},
            {0, -1},
            {0, -2},
            {-1, -1},
            {-1, 1}
        }
    }
}

-- Return a list of offsets for the tiles neighbors
function getHexNeighbors(pos)
    local parity = pos.y % 2 == 0 and 1 or 2
    return neighbors.hex[parity]
end 

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
    
    -- Build GUI from parent view
    local view = e.data.view
    
    -- Create hex grid
    grid = flower.MapImage("hex-tiles.png", width, height, 128, 112, 16)
    grid:setShape(MOAIGridSpace.HEX_SHAPE)
    grid:setLayer(layer)
    
    grid:setRepeat(true, true)
    grid:setPos(0,50)
    
    -- Make the grid touchable
    addTouchEventListeners(grid)
end

function rippleOut(pos, length)
    local randomTile = math.random(1, 4)
    
    local function UpdateTile(newX, newY)
        newX, newY = grid.grid:wrapCoord ( newX, newY )
        grid:setTile(newX, newY, randomTile)
    end
    
    local visited = {}
    local list = {}
    
    table.insert(list, {position = pos, depth = 1})
    
    local counter = 1
    while #list > 0 and counter < length do
        local currentNode = list[1]
        table.remove(list, 1)
        
        flower.Executors.callLaterTime(currentNode.depth / 20, UpdateTile, currentNode.position.x, currentNode.position.y)
        
        local directions = getHexNeighbors(currentNode.position)
        for i, dir in ipairs(directions) do
            local newPos = {x = currentNode.position.x + dir[1], y = currentNode.position.y + dir[2]}
            local key = newPos.x  .. newPos.y
            if not visited[key] then
                visited[key] = true
                table.insert(list, {position = newPos, depth = currentNode.depth + 1})
            end
        end
        
        counter = counter + 1
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
    
    rippleOut({x = xCoord, y = yCoord}, mode == "pattern" and 100 or 8)
    
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