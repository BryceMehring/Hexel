require "lfs"
require "source/utilities/extensions/io"
require "source/gameConfig"

SoundManager = flower.class()

local flower = flower
local MOAIUntzSound = MOAIUntzSound
local soundDisabled = Configuration("Disable Sound")

function SoundManager:init(t)
    t = t or {}
    self.sounds = {}
    self.currentVolume = t.volume or 0.2
    self.soundDir = t.soundDir
    
    if soundDisabled then
        return
    end
    
    if self.soundDir then
        local soundFiles = io.files(self.soundDir)
        for i, file in ipairs(soundFiles) do
            self:addSound(file)
        end
    end
end


function SoundManager:addSound(file)
    if soundDisabled then
        return
    end
    
    local newSound = MOAIUntzSound.new()
    newSound:load(file)
    newSound:setVolume(self.currentVolume)
    
    table.insert(self.sounds, newSound)
    
    return #self.sounds
end

function SoundManager:setVolume(volume)
    for i, sound in pairs(self.sounds) do
        sound:setVolume(volume)
    end
    
    self.currentVolume = volume
end

function SoundManager:play(soundIndex)
    if #self.sounds <= 0 then
        return
    end
    
    if soundIndex and soundIndex >= 1 and soundIndex <= #self.sounds then
        self.currentSound = self.sounds[soundIndex]
        self.currentSound:play()
    end
end

function SoundManager:randomizedPlay()
    if #self.sounds <= 0 then
        return
    end
    
    local randomIndex = math.random(1, #self.sounds)
        
    self.currentSound = self.sounds[randomIndex]
    local soundLength = self.currentSound:getLength()
    
    self.timer = flower.Executors.callLaterTime(soundLength + 1, SoundManager.playCallback, self)

    self.currentSound:play()
end

function SoundManager:playCallback()
    self.currentSound:stop()
    self:randomizedPlay()
end

function SoundManager:stop()
    if self.currentSound then
        self.currentSound:stop()
        flower.Executors.cancel(self.timer)
    end
end