module(..., package.seeall)

require "source/utilities/extensions/io"

MAP_LIST = require "assets/maps/mapList"
ITEM_HEIGHT = 32

local selectedData = nil
local view = nil

function createChildView()
    return widget.UIView {
        scene = nil,
        children = {{
            widget.Button {
                pos = {flower.viewWidth - flower.viewWidth/6, 0},
                size = {flower.viewWidth/6, 39},
                text = "Back",
                onClick = function()
                    flower.closeScene({animation = "fade"})
                    selectedData = nil
                end,
            },
        }},
    }
end

function createMenuList()
    
    local function onClickCallback(item)
        if flower.SceneMgr.transitioning then
            return
        end
        
        if item.path then
            local childView = createChildView()
            local childScene = flower.openScene("source/scenes/singlePlayer", {animation = "fade", mapFile = item.path, view = childView})
            if childScene then
                childView:setScene(childScene)
                selectedData = item
            end
        end
    end
    
    for i, item in ipairs(MAP_LIST) do
        local map = widget.SheetButton{
            pos = {flower.viewWidth * i / 6, flower.viewWidth/6},
            size = {128, 128},
            text = item.title,
            textColor = {0.8, 0.8, 0.8, 1},
            normalTexture = item.image,
            onClick = function()
                onClickCallback(item)
            end,
            parent = view,
        } 
    end
    
end

function resizeMenuList()
--    local itemWidth = flower.viewWidth - 20
--    local itemHeight = ITEM_HEIGHT
    
--    view.children[1]:setPos(flower.viewWidth-flower.viewWidth/6, 0)
--    view.children[1]:setSize(flower.viewWidth/6, 39)
    
--    for i, menuItem in ipairs(menuList) do
--        menuItem:setSize(itemWidth, itemHeight)
--    end
end

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    view = e.data.view
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
