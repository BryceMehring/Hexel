module(..., package.seeall)

-- import
local flower = flower

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(true)
    scene:addChild(layer)
    
    -- TODO: draw hex grid here
   
    line = flower.Line({x = 32, y = 32},
                       {x = 500, y = 500})
    
    line:setColor(0, 1, 0.5, 1)
    line:setLayer(layer)
end

function onStart(e)
end

function onResize(e)
end