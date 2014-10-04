module(..., package.seeall)

-- import
local flower = flower

local hexagonAngle = math.rad(30)
local sideLength = 25

local hexHeight = math.sin(hexagonAngle) * sideLength
local hexRadius = math.cos(hexagonAngle) * sideLength
local hexRectangleHeight = sideLength + 2 * hexHeight
local hexRectangleWidth = 2 * hexRadius

-- TODO: move this somewhere else
-- derived from: https://gist.github.com/zackthehuman/1867663
local function CreateHexVertices(face)
    
    local vertices = {}
    vertices[1] = {x = face.x + hexRadius, y = face.y }
    vertices[2] = {x = face.x + hexRectangleWidth, y = face.y + hexHeight}
    vertices[3] = {x = face.x + hexRectangleWidth, y = face.y + hexHeight + sideLength}
    vertices[4] = {x = face.x + hexRadius, y = face.y + hexRectangleHeight}
    vertices[5] = {x = face.x, y = face.y + sideLength + hexHeight}
    vertices[6] = {x = face.x, y = face.y + hexHeight}
    vertices[7] = vertices[1]
    
    return vertices
end

local group = nil
local layer = nil

function onCreate(e)
    
    -- TODO: clean this up

    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    -- TODO: draw hex grid here
    group = flower.Group(layer)
    
    for i=1, 14 do
        for j=1, 14 do
            group:addChild(flower.Line(CreateHexVertices({x = i * hexRectangleWidth + (j % 2) * hexRadius,
                                                          y = j * (sideLength + hexHeight)})))
        end
    end
    
end

function onStart(e)
end

function onResize(e)
end