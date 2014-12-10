local flower = flower
-- LuaSocket should come with zerobrane
local socket = require("socket")

Server = flower.class()

function Server:init(t)
    self.port = t.port or 48310
    self.server, self.servError = socket.bind("*", self.port)
    
    if self.server then
        self.server:settimeout(0)
        self.client = {}
        local serverThread = MOAICoroutine.new()
        serverThread:run(function()
            while 1 do
                self:run()
                coroutine.yield()
            end
        end)
        print("Network connection info:")
        print(self.server:getsockname())
    end
end

function Server:run()
    local new = self.server:accept()
    if new then
        print("New client connected")
        new:settimeout(0)
        table.insert(self.client, new)
    end
end

function Server:stop()
    if self:isConnected() then
        for i, client in ipairs(self.client) do
            client:close()
        end
        
        if self.server then
            self.server:close()
        end
    end
    
    self.client = nil
    self.server = nil
end

function Server:isConnected()
    if self.server then
        return true
    end
    
    return false, (self.servError or "Unknown error")
end

function Server:isClientsConnected(connections)
    connections = connections or 1
    if #self.client >= connections then
        return true
    end
    
    return false, (self.servError or "Unknown error")
end


function Server:stopIfClosed(e)
    if e == "closed" then
        self.servError = e
        self:stop()
    end
end

function Server:talker(text)
    if self:isConnected() then
        for i, client in ipairs(self.client) do
            local b, e = client:send(text .. "\n")
        end
        --self:stopIfClosed(e)
    end
end

function Server:listener()
    local l = {}
    local e = nil
    if self:isConnected() then
        for i, client in ipairs(self.client) do
            local tempData = client:receive()
            table.insert(l, tempData)
            --self:stopIfClosed(e)
        end
        return l
    end
end