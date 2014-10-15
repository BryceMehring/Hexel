-- TODO: clean this up

module(..., package.seeall)

-- import
local flower = flower

local layer = nil
local grid = nil
local mode = "default"
local width = 50
local height = 100

local lives = 20
local score = 0

-- TODO: Move this logic elsewhere for finding neighbors
local neighbors = {
    hex = {
        {
            {x = 0, y = 2},
            {x = 0, y = -2},
            {x = 0, y = -1},
            {x = 0, y = 1},
            {x = 1, y = -1},
            {x = 1, y = 1},
        },
        {
            {x = 0, y = 2},
            {x = 0, y = -2},
            {x = 0, y = -1},
            {x = 0, y = 1},
            {x = -1, y = -1},
            {x = -1, y = 1}
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

    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)

    buildGrid()
    
    -- Build GUI from parent view
    buildGUI(e.data.view)
    
    -- Make the grid touchable
    addTouchEventListeners(grid)
end

function buildGrid()
    -- Create hex grid
    grid = flower.MapImage("hex-tiles.png", width, height, 128, 112, 16)
    grid:setShape(MOAIGridSpace.HEX_SHAPE)
    grid:setLayer(layer)
    
    grid:setRepeat(false, false)
    grid:setPos(0,50)
end

function buildGUI(view)
    local buttonSize = {flower.viewWidth/6, 39}
    toggleButton = widget.Button {
        size = buttonSize,
        --pos = {flower.viewWidth - 100, 50},
        text = "Toggle Mode",
        parent = view,
        onClick = function()--updateButton,
            mode = mode == "default" and "pattern" or "default"
            score = score + 10
            statusUI:setText(updateStatus())
        end,
    }
    
    clearButton = widget.Button {
        size = buttonSize,
        text = "Clear Grid",
        parent = view,
        onClick = function()
            grid.grid:fill(5)
        end,
    }
    
    saveButton = widget.Button {
        size = buttonSize,
        text = "Save Grid",
        parent = view,
        onClick = function()
            -- TODO: implement
        end,
        enabled = false,
    }
    
    loadButton = widget.Button {
        size = buttonSize,
        text = "Load Grid",
        parent = view,
        onClick = function()
            -- TODO: implement
        end,
        enabled = false,
    }
    
    statusUI = widget.TextBox {
         size = {buttonSize[1], 50},
         text = updateStatus(),
         textSize = 10,
         parent = view,
    }
end

function updateStatus()
   return "Lives: "..lives.."\nScore: "..score.."\nPaint Mode: "..mode
end

function rippleOut(pos, length)   
    local function ValidTile(pos)
        return grid:getTile(pos.x, pos.y) ~= 3
    end
    
    --[[if not ValidTile(pos) then
        return
    end]]
    
    local randomTile = math.random(1, 4)
    local function UpdateTile(newX, newY)
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
            local newPos = {x = currentNode.position.x + dir.x, y = currentNode.position.y + dir.y}
            local key = newPos.x + newPos.y * (width + 1)
            if ValidTile(newPos) and not visited[key] then
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