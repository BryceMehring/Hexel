module(..., package.seeall)

require "source/game/game"
require "source/gui/guiUtilities"

local flower = flower

local singlePlayerGame = nil
local view = nil

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
    
    flower.InputMgr:addEventListener("mouseClick", onMouseEvent)
    flower.InputMgr:addEventListener("mouseMove", onMouseEvent)
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
    flower.InputMgr:removeEventListener("mouseClick", onMouseEvent)
    flower.InputMgr:removeEventListener("mouseMove", onMouseEvent)
    
    singlePlayerGame:paused(false)
    singlePlayerGame:stopped(true)
    singlePlayerGame = nil
end

function onMouseEvent(e)
    if e.type == "mouseClick" then
        if not e.down then
            return
        end
    end
    
    -- TODO: check this later. Is this needed?
    local prop = singlePlayerGame.map:getGrid()

    local x = e.x
    local y = e.y
    x, y = layer:wndToWorld(x, y)
    x, y = prop:worldToModel(x, y)
    
    -- TODO: move this into the Game
    local pos = vector{singlePlayerGame.map:getMOAIGrid():locToCoord(x, y)}
    
    if e.type == "mouseClick" then
        singlePlayerGame:onTouchDown(pos)
    elseif e.type == "mouseMove" then
        singlePlayerGame:onMouseMove(pos)
    else
        error("Unknown input event: " .. e.type)
    end
end