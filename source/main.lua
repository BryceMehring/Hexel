
--require('mobdebug').on()
-- import

flower = require "libraries/flower"
config = require "config"
widget = require "libraries/widget"
themes = require "libraries/themes"

flower.openWindow("Hexel", 1024, 768)

math.randomseed(os.clock())
flower.openScene("scenes/mainMenu")
