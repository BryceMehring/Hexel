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
        updateStatus = updateStatus,
        -- TODO: fill this out
    }

    view = e.data.view
    buildUI("SinglePlayer", e.data.view, singlePlayerGame)

    flower.Runtime:addEventListener("resize", onResize)
    addTouchEventListeners(singlePlayerGame.map.grid)
end

function updateStatus(statusMsg)
   updateStatusText(statusMsg)
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
    singlePlayerGame:paused(false)
    singlePlayerGame:stopped(true)
    singlePlayerGame = nil
end

function addTouchEventListeners(item)
    item:addEventListener("touchDown", item_onTouchDown)
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
    
    -- TODO: move this into the Game
    local xCoord, yCoord = singlePlayerGame.map:GetMOAIGrid():locToCoord(x, y)
    
    singlePlayerGame:onTouchDown(vector{xCoord, yCoord})
    
    prop.touchDown = true
    prop.touchIdx = e.idx
    prop.touchLast = vector{e.wx, e.wy}
end