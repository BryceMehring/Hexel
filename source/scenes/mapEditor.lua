-- TODO: clean this up!

module(..., package.seeall)

require "source/gridNeighbors"
require "source/gui/guiUtilities"
require "source/utilities/vector"

-- import
local flower = flower

-- local variables
local layer = nil
local view = nil

-- MapEditor singleton
MapEditor = {}
MapEditor.texture = "hex-tiles.png"
MapEditor.width = 50
MapEditor.height = 100
MapEditor.tileWidth = 128
MapEditor.tileHeight = 111
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
-- This function is used by the GuiUtilities file to generate
-- the status field in the UI
function MapEditor.generateStatus()
    return "Current Algorithm: " .. MapEditor.currentAlgorithm ..
        "\nCurrent Color: " .. MapEditor.currentColor
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
        return pos[1] >= 1 and pos[1] <= MapEditor.width and
               pos[2] >= 1 and pos[2] <= MapEditor.height and
               MapEditor.grid:getTile(pos[1], pos[2]) ~= 3
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
            local newPos = currentNode.position + dir
            local key = newPos[1] + newPos[2] * (MapEditor.width + 1)
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
    MapEditor.grid:setTile(pos[1], pos[2], tile)
end

-- Create a list of all algorithms that the map editor supports
for k, v in pairs(MapEditor) do
    if type(v) == "function" and string.match(k, "^_algorithm") then
        table.insert(MapEditor.algorithms, v)
    end
end

function MapEditor.setColor(colorNum)
    MapEditor.currentColor = colorNum
end

function onCreate(e)

    view = e.data.view

    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)

    MapEditor.buildGrid()
    
    -- Build GUI from parent view
    buildUI("MapEditor", view, MapEditor, MapEditor.serializeGrid, nil, MapEditor.setColor)
    
    MapEditor.serializeGrid(saveFile, true)
    
    -- Make the grid touchable
    -- TODO: move this code into the map editor
    addTouchEventListeners(MapEditor.grid)
    flower.Runtime:addEventListener("resize", onResize)
end

function updateLayout()
    _resizeComponents(view)
end

function onResize(e)
    updateLayout()
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

    local x = e.wx
    local y = e.wy
    x, y = layer:wndToWorld(x, y)
    x, y = prop:worldToModel(x, y)
    
    -- TODO: move this into the map editor
    local xCoord, yCoord = MapEditor.grid.grid:locToCoord(x, y)
    
    MapEditor.onTouchDown(vector{xCoord, yCoord})
    
    prop.touchDown = true
    prop.touchIdx = e.idx
    prop.touchLast = vector{e.wx, e.wy}
end

function item_onTouchUp(e)
    
    local prop = e.prop
    if prop == nil or prop.touchDown and prop.touchIdx ~= e.idx then
        return
    end

    prop.touchDown = false
    prop.touchIdx = nil
    prop.touchLast = nil
end

function item_onTouchMove(e)
    
    local prop = e.prop
    if prop == nil or not prop.touchDown then
        return
    end
    
    local moveVec = {e.wx, e.wy} - prop.touchLast
    prop:addLoc(moveVec[1], moveVec[2], 0)
    prop.touchLast = vector{e.wx, e.wy}
end

function item_onTouchCancel(e)

    local prop = e.prop
    if prop == nil or not prop.touchDown then
        return
    end
    
    prop.touchDown = false
    prop.touchIdx = nil
    prop.touchLast = nil
end
