local flower = flower
-- LuaSocket should come with zerobrane
local socket = require("socket")

Client = flower.class()

function Client:init(t)
    self.serverIP = t.serverIP or "localhost"
    self.port = t.port or 48310
    self:run()
end

function Client:run()
    enableDebugging()
    self.client = nil
    
    self.client, self.servError = socket.connect(self.serverIP, self.port)
    if self.client then
       self.client:settimeout(0) 
    end
end

function Client:stop()
    if self:isConnected() then

        self.client:close()

        
        if self.server then
            self.server:close()
        end
    end
    
    self.client = nil
    self.server = nil
end

function Client:isConnected()
    if self.client  then
        return true
    end
    
    return false, (self.servError or "Unknown error")
end

function Client:isServer()
    return self.server and true
end

function Client:stopIfClosed(e)
    if e == "closed" then
        self.servError = e
        self:stop()
    end
end

function Client:talker(text)
    if self:isConnected() then
        local b, e = self.client:send(text .. "\n")
        self:stopIfClosed(e)
    end
end

function Client:listener()
    if self:isConnected() then
        local l, e = nil
           l, e = self.client:receive()
        self:stopIfClosed(e)
        
        return l
    end
end