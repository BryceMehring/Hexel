module(..., package.seeall)

MAP_LIST = require "maps/mapList"
ITEM_HEIGHT = 32

function createChildView()
    return widget.UIView {
        scene = nil,
        layout = widget.BoxLayout {
            align = {"right", "top"},
        },
    }
end

function createMenuList()
    menuList = {}
    local itemWidth = flower.viewWidth - 20
    local itemHeight = ITEM_HEIGHT
    
    for i, item in ipairs(MAP_LIST) do
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
end

function menuItem_onTouchDown(e)
    if flower.SceneMgr.transitioning then
        return
    end

    local t = e.target
    local data = t and t.data
    if data and data.path then
        dofile( data.path )
        local childView = createChildView()
        local childScene = flower.openScene("scenes/game", {animation = "fade", params = nil, view = childView})
        if childScene then
            childView:setScene(childScene)
            selectedData = item
        end
        --local input = assert(io.input(data.path))
        --local dataz = input:read("*a")
        --input:close()
        --print(dataz)
    end
end