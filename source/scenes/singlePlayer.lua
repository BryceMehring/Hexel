module(..., package.seeall)

require "source/game/game"
require "source/gui/guiUtilities"

local flower = flower

local singlePlayerGame = nil
local view = nil
local mouseEvents = {
    "mouseClick",
    "mouseMove",
    "mouseRightClick",
}

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    singlePlayerGame = Game {
        layer = layer,
        mapFile = e.data.mapFile,
        view = e.data.view,
        -- TODO: fill this out
    }

    view = e.data.view
    buildUI("SinglePlayer", e.data.view, singlePlayerGame)

    flower.Runtime:addEventListener("resize", onResize)
    
    for i, v in ipairs(mouseEvents) do
        flower.InputMgr:addEventListener(v, onMouseEvent)
    end
end

function updateLayout()
    _resizeComponents(view)
end

function onResize(e)
    updateLayout()
end

function onStart(e)
    singlePlayerGame:stopped(false)
    singlePlayerGame:run()
end

function onStop(e)
    for i, v in ipairs(mouseEvents) do
        flower.InputMgr:removeEventListener(v, onMouseEvent)
    end
    
    singlePlayerGame:paused(false)
    singlePlayerGame:stopped(true)
    singlePlayerGame = nil
end

function onMouseEvent(e)
    if e.type ~= "mouseMove" then
        if not e.down then
            return
        end
    end
    
    local pos = singlePlayerGame.map:screenToGridSpace(e.x, e.y, layer)
    
    if e.type == "mouseClick" or e.type == "mouseRightClick" then
        singlePlayerGame:onTouchDown(pos, e.type)
    elseif e.type == "mouseMove" then
        singlePlayerGame:onMouseMove(pos)
    else
        error("Unknown input event: " .. e.type)
    end
end