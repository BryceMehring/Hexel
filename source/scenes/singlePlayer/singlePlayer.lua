module(..., package.seeall)
require "utilities/extensions/math"

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
local timer = nil

function onCreate(e)
    
    -- TODO: clean this up

    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    -- TODO: draw hex grid here
    group = flower.Group(layer)
    
    for i=1, 14 do
        for j=1, 14 do
            local hexTile = flower.Line(CreateHexVertices({x = i * hexRectangleWidth + (j % 4) * hexRadius,
                                                           y = j * (sideLength + hexHeight)}))
            group:addChild(hexTile)
        end
    end
    
    timer = flower.Executors.callLoopTime(3.0, function()
        -- TODO: maybe this could be pushed into flower?
        for i, v in ipairs(group.children) do
            local r, g, b = v:getColor()
            local randomR, randomG, randomB = unpack(math.generateRandomNumbers(0.1, 0.9, 3))
            v:moveColor(randomR - r, randomG - g, randomB - b, 1.0, 1.0)
        end
    end)
    
end

function onStart(e)
end

function onStop(e)
    flower.Executors.cancel(timer)
end

function onResize(e)
end