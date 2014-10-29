module(..., package.seeall)

require "source/scenes/singlePlayer/game"
require "source/guiUtilities"

local singlePlayerGame = nil

function onCreate(e)
    local layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    singlePlayerGame = game {
        layer = layer,
        map = e.data.map,
        -- TODO: fill this out
    }

    buildUI("SinglePlayer", e.data.view, singlePlayerGame)
    
    -- TODO: move this into the Game
    addTouchEventListeners(singlePlayerGame.grid)
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
    local xCoord, yCoord = singlePlayerGame.grid.grid:locToCoord(x, y)
    
    singlePlayerGame:onTouchDown(vector{xCoord, yCoord})
    
    prop.touchDown = true
    prop.touchIdx = e.idx
    prop.touchLast = vector{e.wx, e.wy}
end