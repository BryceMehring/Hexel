
--require('mobdebug').on()
-- import

flower = require "source/libraries/flower"
config = require "source/engineConfig"
widget = require "source/libraries/widget"
themes = require "source/libraries/themes"
require "source/gameConfig"

flower.openWindow("Hexel", 1024, 768)

math.randomseed(os.clock())
flower.openScene("source/scenes/splashScreen", {animation = "crossFade"})

if not Configuration("Disable Sound") then
    MOAIUntzSystem.initialize(44100, 1000)
end
