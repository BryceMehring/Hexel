module(..., package.seeall)

require "source/scenes/singlePlayer/game"
require "source/guiUtilities"

function onCreate(e)
    -- TODO: avoid setting the layer directly into the game singleton
    Game.layer = flower.Layer()
    Game.layer:setTouchEnabled(true)
    scene:addChild(Game.layer)

    Game.buildGrid()
    buildUI("SinglePlayer", e.data.view, Game)
end

function onStart(e)
    Game.stopped(false)
    Game.run()
end

function onStop(e)
    Game.paused(false)
    Game.stopped(true)
end