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