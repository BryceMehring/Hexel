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
    
    self.nfe = NetworkFrameworkEntity{}
    local connected, networkError = self.nfe:isConnected()
    if not connected then
        return
    end        
    
    if self.nfe.isServer() then
        multiplayerGame =  Server {
            layer = layer,
            view = e.data.view
            nfe = self.nfe,
        }
    else
        multiplayerGame = Client {
            layer = layer,
            view = e.data.view
            nfe = self.nfe,
        }
    end
    
--    multiPlayerGame = VersusGame {
--        layer = layer,
--        view = e.data.view,
--        -- TODO: fill this out
--    }

    view = e.data.view
    buildUI("SinglePlayer", e.data.view,
        multiPlayerGame)

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