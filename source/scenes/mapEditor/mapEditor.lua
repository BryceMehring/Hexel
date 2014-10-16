-- TODO: clean this up!

module(..., package.seeall)

-- import
local flower = flower

-- local variables
local layer = nil

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

-- MapEditor singleton
MapEditor = {}
MapEditor.texture = "hex-tiles.png"
MapEditor.width = 50
MapEditor.height = 100
MapEditor.tileWidth = 128
MapEditor.tileHeight = 112
MapEditor.radius = 16
MapEditor.saveFile = "grid.sav"
MapEditor.currentAlgorithm = 1
MapEditor.currentColor = 1
MapEditor.algorithms = {}

function MapEditor.buildGrid(params)
    params = params or {}
    MapEditor.texture = params.texture or MapEditor.texture
    MapEditor.width = params.width or MapEditor.width
    MapEditor.height = params.height or MapEditor.height
    MapEditor.tileWidth = params.tileWidth or MapEditor.tileWidth
    MapEditor.tileHeight = params.tileHeight or MapEditor.tileHeight
    MapEditor.radius = params.radius or MapEditor.radius
    
    MapEditor.grid = flower.MapImage(MapEditor.texture,
                                      MapEditor.width, 
                                      MapEditor.height,
                                      MapEditor.tileWidth,
                                      MapEditor.tileHeight,
                                      MapEditor.radius)
                                  
    MapEditor.grid:setShape(MOAIGridSpace.HEX_SHAPE)
    MapEditor.grid:setLayer(layer)
end

function MapEditor.buildGUI(view)
    local buttonSize = {flower.viewWidth/6, 39}
    MapEditor.toggleModeButton = widget.Button {
        size = buttonSize,
        text = "Toggle Mode",
        parent = view,
        onClick = function()
            
            -- Loop over all algorithms
            MapEditor.currentAlgorithm = (MapEditor.currentAlgorithm + 1)
            
            if MapEditor.currentAlgorithm > #MapEditor.algorithms then
                MapEditor.currentAlgorithm = 1
            end
            
            MapEditor.statusUI:setText(MapEditor._updateStatus())
        end,
    }
    
    MapEditor.toggleColorModeButton = widget.Button {
        size = buttonSize,
        text = "Toggle Color",
        parent = view,
        onClick = function()
            MapEditor.currentColor = MapEditor.currentColor + 1
            if MapEditor.currentColor > 5 then
                MapEditor.currentColor = 1
            end
            MapEditor.statusUI:setText(MapEditor._updateStatus())
        end,
    }
    
    MapEditor.clearButton = widget.Button {
        size = buttonSize,
        text = "Clear Grid",
        parent = view,
        onClick = function()
            MapEditor.grid.grid:fill(5)
        end,
    }
    
    MapEditor.saveButton = widget.Button {
        size = buttonSize,
        text = "Save Grid",
        parent = view,
        onClick = function()
            MapEditor.serializeGrid(saveFile)
        end,
        enabled = true,
    }
    
    MapEditor.loadButton = widget.Button {
        size = buttonSize,
        text = "Load Grid",
        parent = view,
        onClick = function()
            -- TODO: implement
        end,
        enabled = false,
    }
    
    MapEditor.statusUI = widget.TextBox {
         size = {buttonSize[1], 70},
         text = MapEditor._updateStatus(),
         textSize = 10,
         parent = view,
    }
end

-- Load/Save grid to file
function MapEditor.serializeGrid(file, streamIn)
    file = file or MapEditor.saveFile
    streamIn = streamIn or false
    local fileStream = MOAIFileStream.new()
    local success = fileStream:open(file, streamIn and MOAIFileStream.READ or MOAIFileStream.READ_WRITE_NEW)
    if success then
        if streamIn then
            MapEditor.grid.grid:streamTilesIn(fileStream)
        else
            MapEditor.grid.grid:streamTilesOut(fileStream)
        end
        fileStream:close()
    end
end

function MapEditor._updateStatus()
   return "\nPaint Mode: " .. MapEditor.currentAlgorithm ..
          "\nColor Mode: " .. MapEditor.currentColor
end

function MapEditor.onTouchDown(pos)
    MapEditor.algorithms[MapEditor.currentAlgorithm](pos)
end

-- TODO: move these painting algorithms into another file
function MapEditor._algorithmRippleOut(pos)
    local function ValidTile(pos)
        return pos.x >= 1 and pos.x <= MapEditor.width and
               pos.y >= 1 and pos.y <= MapEditor.height and
               MapEditor.grid:getTile(pos.x, pos.y) ~= 3
    end
    
    --[[if not ValidTile(pos) then
        return
    end]]
    
    local visited = {}
    local list = {}
    
    table.insert(list, {position = pos, depth = 1})
    
    local counter = 1
    while #list > 0 and counter < 100 do
        local currentNode = list[1]
        table.remove(list, 1)
        
        flower.Executors.callLaterTime(currentNode.depth / 20, MapEditor._algorithmFillSingleTile, currentNode.position)
        
        local directions = getHexNeighbors(currentNode.position)
        for i, dir in ipairs(directions) do
            local newPos = {x = currentNode.position.x + dir.x, y = currentNode.position.y + dir.y}
            local key = newPos.x + newPos.y * (MapEditor.width + 1)
            if ValidTile(newPos) and not visited[key] then
                visited[key] = true
                table.insert(list, {position = newPos, depth = currentNode.depth + 1})
            end
        end
        
        counter = counter + 1
    end
end

function MapEditor._algorithmFillSingleTile(pos, tile)
    tile = tile or MapEditor.currentColor
    MapEditor.grid:setTile(pos.x, pos.y, tile)
end

-- Create a list of all algorithms that the map editor supports
for k, v in pairs(MapEditor) do
    if type(v) == "function" and string.match(k, "^_algorithm") then
        table.insert(MapEditor.algorithms, v)
    end
end

function onCreate(e)

    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)

    MapEditor.buildGrid()
    
    -- Build GUI from parent view
    MapEditor.buildGUI(e.data.view)
    
    MapEditor.serializeGrid(saveFile, true)
    
    -- Make the grid touchable
    -- TODO: move this code into the map editor
    addTouchEventListeners(MapEditor.grid)
end

function onStart(e)
end

function onStop(e)
end

function addTouchEventListeners(item)
    item:addEventListener("touchDown", item_onTouchDown)
    item:addEventListener("touchUp", item_onTouchUp)
    item:addEventListener("touchMove", item_onTouchMove)
    item:addEventListener("touchCancel", item_onTouchCancel)
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
    
    -- TODO: move this into the map editor
    local xCoord, yCoord = MapEditor.grid.grid:locToCoord(x, y)
    
    MapEditor.onTouchDown({x = xCoord, y = yCoord})
    
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
