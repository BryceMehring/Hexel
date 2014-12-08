module(..., package.seeall)

require "source/networking/networkFrameworkEntity"
local JSON = require "source/libraries/JSON"

--require "source/game/versusGame"
require "source/game/server"
require "source/game/client"
require "source/gui/guiUtilities"

local flower = flower

local multiPlayerGame = nil
local view = nil

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    local my_nfe = NetworkFrameworkEntity{}
    local connected, networkError = my_nfe:isConnected()
    if not connected then
        return
    end
    
    if my_nfe:isServer() then
        multiPlayerGame =  Server {
            mapFile = "assets/maps/map1.lua",
            layer = layer,
            view = e.data.view,
            nfe = my_nfe,
        }
        print("server")
        view = e.data.view
    else
        multiPlayerGame = Client {
            layer = layer,
            view = e.data.view,
            nfe = my_nfe,
        }
        print("client")
        view = e.data.view
        buildUI("SinglePlayer", e.data.view, multiPlayerGame)
    end

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
    multiPlayerGame:stopped(false)
    multiPlayerGame:run()
end

function onStop(e)
    flower.InputMgr:removeEventListener("mouseClick", item_onTouchDown)
    multiPlayerGame:paused(false)
    multiPlayerGame:stopped(true)
    multiPlayerGame = nil
end

function item_onTouchDown(e)
    if not e.down then
        return
    end
    
    -- TODO: check this later. Is this needed?

    local x = e.x
    local y = e.y
    x, y = layer:wndToWorld(x, y)
    --x, y = prop:worldToModel(x, y)
    


end