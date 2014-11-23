
--require('mobdebug').on()
-- import

flower = require "source/libraries/flower"
config = require "source/config"
widget = require "source/libraries/widget"
themes = require "source/libraries/themes"

flower.openWindow("Hexel", 1024, 768)

math.randomseed(os.clock())
flower.openScene("source/scenes/splashScreen", {animation = "crossFade"})

MOAIUntzSystem.initialize(44100, 1000)
