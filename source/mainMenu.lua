module(..., package.seeall)

--------------------------------------------------------------------------------
-- Constraints
--------------------------------------------------------------------------------

MENU_ITEMS = require "scenes/sceneList"
ITEM_HEIGHT = 32

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local selectedData = nil
local backButton = nil

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

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

function createMenuList()
    menuList = {}
    local itemWidth = flower.viewWidth - 20
    local itemHeight = ITEM_HEIGHT
    
    for i, item in ipairs(MENU_ITEMS) do
        local menuItem = createMenuItem(item, itemWidth, itemHeight)
        menuItem:setPos(10, i * 40)
        table.insert(menuList, menuItem)
    end
end

function createMenuItem(item, itemWidth, itemHeight)
    local rect = flower.Rect(itemWidth, itemHeight)
    rect:setColor(0, 0, 0.5, 1)

    local label = flower.Label(item.title, itemWidth, itemHeight)

    local menuItem = flower.Group(layer, itemWidth, itemHeight)
    menuItem.data = item
    menuItem:addChild(rect)
    menuItem:addChild(label)
    menuItem:addEventListener("touchDown", menuItem_onTouchDown)
    menuItem:addEventListener("touchMove", menuItem_onTouchMove)
    
    function menuItem:setSize(width, height)
        flower.Group.setSize(self, width, height)
        for i, child in ipairs(self.children) do
            child:setSize(width, height)
        end
    end
    
    return menuItem    
end

function resizeMenuList()
    local itemWidth = flower.viewWidth - 20
    local itemHeight = ITEM_HEIGHT
    
    for i, menuItem in ipairs(menuList) do
        menuItem:setSize(itemWidth, itemHeight)
    end
end

function resetPosition()
    if backButton then
       backButton:setPos(flower.viewWidth - 100, 0)
    end
end

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    createMenuList()
    
    flower.Runtime:addEventListener("resize", onResize)
end

function onStart(e)
    -- debug
    MOAISim.forceGarbageCollection()
    MOAISim.reportHistogram()

end

function onResize(e)
    resizeMenuList()
    resetPosition()
end

function menuItem_onTouchDown(e)
    if flower.SceneMgr.transitioning then
        return
    end

    local t = e.target
    local data = t and t.data
    if data and data.scene then
        local childScene = flower.openScene(data.scene, {animation = data.openAnime})
        if childScene then
            selectedData = data
            createBackButton(childScene)
        end
    end
end

function backButton_onTouchDown(e)
    if flower.SceneMgr.transitioning then
        return
    end
    
    flower.closeScene({animation = selectedData.closeAnime})
    selectedData = nil
    backButton = nil
end

function menuItem_onTouchMove(e)
    print("TEST")
end
