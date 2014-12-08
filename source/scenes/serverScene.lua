module(..., package.seeall)

require "source/networking/client"
require "source/networking/server"
local JSON = require "source/libraries/JSON"

--require "source/game/versusGame"
require "source/game/serverGame"
require "source/game/clientGame"
require "source/gui/guiUtilities"

local mouseEvents = {
    "mouseClick",
    "mouseMove",
    "mouseRightClick",
}

local flower = flower

local serverGame = nil
local view = nil

function onCreate(e)
    --layer = flower.Layer()
    --layer:setTouchEnabled(true)
    --scene:addChild(layer)
    
    local my_server = Server{}
--    local connected, networkError = my_server:isConnected()
--    if not connected then
--        return
--    end
    

    serverGame =  ServerGame {
        mapFile = "assets/maps/map1.lua",
        --layer = layer,
        view = e.data.view,
        server = my_server,
    }
    view = e.data.view

    flower.Runtime:addEventListener("resize", onResize)
end

function updateLayout()
    _resizeComponents(view)
end

function onResize(e)
    updateLayout()
end

function onStart(e)
    serverGame:stopped(false)
    serverGame:run()
end

function onStop(e)
    for i, v in ipairs(mouseEvents) do
        flower.InputMgr:removeEventListener(v, onMouseEvent)
    end
    serverGame:paused(false)
    serverGame:stopped(true)
    serverGame = nil
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

function onMouseEvent(e)
    if serverGame.map then
        if e.type ~= "mouseMove" then
            if not e.down then
                return
            end
        end
        
        local pos = serverGame.map:screenToGridSpace(e.x, e.y, layer)
        
        if e.type == "mouseClick" or e.type == "mouseRightClick" then
            serverGame:onTouchDown(pos, e.type)
        elseif e.type == "mouseMove" then
            serverGame:onMouseMove(pos)
        else
            error("Unknown input event: " .. e.type)
        end
    end
end