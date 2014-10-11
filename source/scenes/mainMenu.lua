module(..., package.seeall)

--------------------------------------------------------------------------------
-- Constraints
--------------------------------------------------------------------------------

local MENU_ITEMS = require "scenes/sceneList"
local ITEM_WIDTH = flower.viewWidth / 2
local ITEM_HEIGHT = 60

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local selectedData = nil
local backButton = nil

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

-- TODO: convert this to use the new widget library
function createBackButton(childScene)
    local layer = flower.Layer()
    layer:setTouchEnabled(true)
    childScene:addChild(layer)
    
    local rect = flower.Rect(100, ITEM_HEIGHT)
    rect:setColor(0, 0, 0.5, 1)
    rect:setLayer(layer)
    
    local label = flower.Label("Back", 100, ITEM_HEIGHT)
    
    backButton = flower.Group(layer)
    backButton:setPos(flower.viewWidth - 100, 0)
    backButton:addChild(rect)
    backButton:addChild(label)
    backButton:addEventListener("touchDown", backButton_onTouchDown)
end

-- Populates the main menu with buttons for their corresponding state.
function createMenuList()
    menuList = {}
    
    local function onClickCallback(item)
        if item.scene then
            local childScene = flower.openScene(item.scene, {animation = item.openAnime, params = item.params})
            if childScene then
                selectedData = item
                createBackButton(childScene)
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
            align = {"center", "center"},
        },
    }
    
    createMenuList()
    
    -- TODO: have the quit button actually quit the game.
    local quitButton = widget.Button {
        size = {ITEM_WIDTH, ITEM_HEIGHT},
        text = "Quit",
        onClick = nil,
        onDown = nil,
        onUp = nil,
        enabled = false,
    }
    
    view:addChild(quitButton)
end

function onStart(e)
end

function backButton_onTouchDown(e)
    if flower.SceneMgr.transitioning then
        return
    end
    
    flower.closeScene({animation = selectedData.closeAnime})
    selectedData = nil
    backButton = nil
end
