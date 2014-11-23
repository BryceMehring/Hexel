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
    
    flower.InputMgr:addEventListener("mouseClick", item_onTouchDown)
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
    flower.InputMgr:removeEventListener("mouseClick", item_onTouchDown)
    singlePlayerGame:paused(false)
    singlePlayerGame:stopped(true)
    singlePlayerGame = nil
end

function item_onTouchDown(e)
    if not e.down then
        return
    end
    
    -- TODO: check this later. Is this needed?
    local prop = singlePlayerGame.map:getGrid()

    local x = e.x
    local y = e.y
    x, y = layer:wndToWorld(x, y)
    x, y = prop:worldToModel(x, y)
    
    -- TODO: move this into the Game
    local xCoord, yCoord = singlePlayerGame.map:getMOAIGrid():locToCoord(x, y)
    
    singlePlayerGame:onTouchDown(vector{xCoord, yCoord})
end