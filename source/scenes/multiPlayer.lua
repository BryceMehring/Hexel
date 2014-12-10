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

local multiPlayerGame = nil
local view = nil
local params = nil

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    view = e.data.view
    
    popupView = widget.UIView {
        scene = scene,
        layout = widget.BoxLayout {
            align = {"center", "center"},
        },
    }
    
    params = e.data.params  
end

function updateLayout()
    _resizeComponents(view)
end

function onResize(e)
    updateLayout()
end

function onStart(e)
    if params.mode == "client" then
        local my_client = Client{}
        local connected, networkError = my_client:isConnected()
        if not connected then
            local box = generateMsgBox(nil, nil, "Cannot connect to server", popupView)
            box:showPopup()
            return
        end

        multiPlayerGame = ClientGame {
            layer = layer,
            view = e.data.view,
            client = my_client,
            popupView = popupView,
        }
    
        buildUI("SinglePlayer", view, multiPlayerGame)

        for i, v in ipairs(mouseEvents) do
            flower.InputMgr:addEventListener(v, onMouseEvent)
        end
    elseif params.mode == "server" then
        local my_server = Server{}
        
        if not my_server:isConnected() then
            local box = generateMsgBox(nil, nil, "Cannot create server", popupView)
            box:showPopup()
            return
        end
        
        multiPlayerGame =  ServerGame {
            layer = layer,
            mapFile = "assets/maps/map1.lua",
            view = e.data.view,
            server = my_server,
        }
    end
    
    flower.Runtime:addEventListener("resize", onResize)
    
    multiPlayerGame:stopped(false)
    multiPlayerGame:run()
end

function onStop(e)
    for i, v in ipairs(mouseEvents) do
        flower.InputMgr:removeEventListener(v, onMouseEvent)
    end
    
    if multiPlayerGame then
        multiPlayerGame:paused(false)
        multiPlayerGame:stopped(true)
        multiPlayerGame = nil
    end
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
    if multiPlayerGame.map then
        if e.type ~= "mouseMove" then
            if not e.down then
                return
            end
        end
        
        local pos = multiPlayerGame.map:screenToGridSpace(e.x, e.y, layer)
        
        if e.type == "mouseClick" or e.type == "mouseRightClick" then
            multiPlayerGame:onTouchDown(pos, e.type)
        elseif e.type == "mouseMove" then
            multiPlayerGame:onMouseMove(pos)
        else
            error("Unknown input event: " .. e.type)
        end
    end
end