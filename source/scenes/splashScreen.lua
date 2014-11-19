module(..., package.seeall)

require "source/sound/sound"

local flower = flower
local widget = widget

local view = nil

function onCreate(e)
    layer = flower.Layer()
    layer:setTouchEnabled(false)
    scene:addChild(layer)
    
    view = widget.UIView {
        scene = scene,
        layout = widget.BoxLayout {
            gap = {5, 5},
            padding = {10, 10, 10, 10},
            align = {"center", "top"},
        },
        children = {{
            widget.Button {
                size = {0, flower.viewHeight/5}
            },
            flower.Label("Little Red Comet Games", nil, nil, nil, 64),
            widget.Button {
                normalTexture = "logo.png",
                size = {flower.viewWidth/4, flower.viewWidth/4},
            },
            flower.Label("Loading assets, please wait...", nil, nil, nil, 24),
        }}
    }
    
end

function onStart(e)
    flower.Executors.callLaterFrame(1, function()
        loadResources()
        flower.openScene("source/scenes/mainMenu", {animation="fade"})
        flower.closeScene()
    end)
end

function createEvent()
    print("please")
    loadResources()
    flower.openScene("source/scenes/mainMenu")
end

function loadResources()
    soundManager = SoundManager {
        soundDir = "assets/sounds/soundtrack/",
    }
end

