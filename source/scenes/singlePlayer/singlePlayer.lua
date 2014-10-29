module(..., package.seeall)

require "source/scenes/singlePlayer/game"
require "source/guiUtilities"

local flower = flower

local singlePlayerGame = nil
local view = nil

function onCreate(e)
    local layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    singlePlayerGame = game {
        layer = layer,
        map = e.data.map,
        -- TODO: fill this out
    }
    
    view = e.data.view

    buildUI("SinglePlayer", e.data.view, singlePlayerGame)
    flower.Runtime:addEventListener("resize", onResize)
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