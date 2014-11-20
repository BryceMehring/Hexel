module(..., package.seeall)

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local flower = flower
local widget = widget
require "source/gui/guiUtilities"

--------------------------------------------------------------------------------
-- Constraints
--------------------------------------------------------------------------------

local MENU_ITEMS = require "source/scenes/sceneList"
local ITEM_WIDTH = flower.viewWidth / 2
local ITEM_HEIGHT = 60

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local selectedData = nil
local backButton = nil
local view = nil

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

-- Populates the main menu with buttons for their corresponding state.
function createMenuList()
    
    local function onClickCallback(item)
        if flower.SceneMgr.transitioning then
            return
        end
        
        if item.scene then
            local childView = createChildView(item.closeAnime, selectedData)
            local childScene = flower.openScene(item.scene, {animation = item.openAnime, params = item.params, view = childView})
            if childScene then
                childView:setScene(childScene)
                selectedData = item
            end
        end
    end
    
    for i, item in ipairs(MENU_ITEMS) do
        local menuItem = widget.Button {
            size = {ITEM_WIDTH, ITEM_HEIGHT},
            text = item.title,
            onClick = function()
                onClickCallback(item)
            end,
            enabled = item.scene ~= nil,
        }
        
        view:addChild(menuItem)
    end
    
    local quitButton = widget.Button {
        size = {ITEM_WIDTH, ITEM_HEIGHT},
        text = "Quit",
        onClick = function()
            os.exit()
        end,
        enabled = true,
    }
    
    view:addChild(quitButton)
end

function updateLayout()
    local yOffset = (flower.viewHeight - ((#MENU_ITEMS + 1) * (ITEM_HEIGHT + 5)))/2
    local xOffset = (flower.viewWidth - ITEM_WIDTH)/2
    
    for i, item in ipairs(view.children) do
        item:setPos(xOffset, yOffset + (i-1)*(ITEM_HEIGHT + 5))
    end
end

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    view = widget.UIView {
        scene = scene,
        layout = widget.BoxLayout {
            gap = {5, 5},
            padding = {10, 10, 10, 10},
            align = {"center", "top"},
        },
        children = {{
            flower.Label("Hexel", nil, nil, nil, 128)
        }}
    }
    
    createMenuList()
    flower.Runtime:addEventListener("resize", onResize)
end

function onStart(e)
end

function onResize(e)
    updateLayout()
end