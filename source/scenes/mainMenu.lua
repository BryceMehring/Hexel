module(..., package.seeall)

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local flower = flower
local widget = widget

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

-- Create view for a child state wtih a back button
function createChildView()
    return widget.UIView {
        scene = nil,
        --[[layout = widget.BoxLayout {
            align = {"right", "top"},
        },--]]
        children = {{
            widget.Button {
                pos = {flower.viewWidth - flower.viewWidth/6, 0},
                size = {flower.viewWidth/6, 39},
                text = "Back",
                onClick = function()
                    flower.closeScene({animation = selectedData.closeAnime})
                    selectedData = nil
                end,
            },
        }},
    }
end

-- Populates the main menu with buttons for their corresponding state.
function createMenuList()
    
    local function onClickCallback(item)
        if item.scene then
            local childView = createChildView()
            local childScene = flower.openScene(item.scene, {animation = item.openAnime, params = item.params, view = childView})
            if childScene then
                childView:setScene(childScene)
                selectedData = item
            end
        end
    end
    
    yOffset = (flower.viewHeight - ((#MENU_ITEMS + 1) * (ITEM_HEIGHT + 5)))/2
    xOffset = (flower.viewWidth - ITEM_WIDTH)/2
    for i, item in ipairs(MENU_ITEMS) do
        local menuItem = widget.Button {
            size = {ITEM_WIDTH, ITEM_HEIGHT},
            pos = {xOffset, yOffset + (i-1)*(ITEM_HEIGHT + 5)},
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
        pos = {xOffset, yOffset + (#MENU_ITEMS)*(ITEM_HEIGHT + 5)},
        text = "Quit",
        onClick = function()
            os.exit()
        end,
        onDown = nil,
        onUp = nil,
        enabled = true,
    }
    
    view:addChild(quitButton)
end

function updateLayout()
    yOffset = (flower.viewHeight - ((#MENU_ITEMS + 1) * (ITEM_HEIGHT + 5)))/2
    xOffset = (flower.viewWidth - ITEM_WIDTH)/2
    
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
    }
    
    createMenuList()
    flower.Runtime:addEventListener("resize", onResize)

end

function onStart(e)
end

function onResize(e)
    updateLayout()
end