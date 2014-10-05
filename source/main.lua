
--require('mobdebug').on()
-- import

flower = require "libraries/flower"
config = require "config"
flower.openWindow("Hexel", 800, 600)

math.randomseed(os.clock())
flower.openScene("scenes/mainMenu")
