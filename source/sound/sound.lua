require "lfs"
require "source/utilities/extensions/io"

SoundManager = flower.class()

local flower = flower
local MOAIUntzSound = MOAIUntzSound

function SoundManager:init(t)
    t = t or {}
    self.sounds = {}
    self.currentSound = nil
    self.soundDir = t.soundDir or "assets/sounds/"
    
    local soundFiles = io.files(self.soundDir)
    for i, file in ipairs(soundFiles) do
        self:addSound(file)
    end
end


function SoundManager:addSound(file)
    local newSound = MOAIUntzSound.new()
    newSound:load(file)
    newSound:setVolume(0.2)
    
    table.insert(self.sounds, newSound)
end

function SoundManager:play()
    
    if #self.sounds <= 0 then
        return
    end
    
    local randomIndex = math.random(1, #self.sounds)
    
    self.randomSound = self.sounds[randomIndex]
    local soungLength = self.randomSound:getLength()
    
    self.timer = flower.Executors.callLaterTime(soungLength + 1, SoundManager.playCallback, self)

    self.randomSound:play()
end

function SoundManager:playCallback()
    self.randomSound:stop()
    self:play()
end

function SoundManager:stop()
    if self.randomSound then
        self.randomSound:stop()
        flower.Executors.cancel(self.timer)
    end
end