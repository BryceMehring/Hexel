local flower = flower
-- LuaSocket should come with zerobrane
local socket = require("socket")

NetworkFrameworkEntity = flower.class()

function NetworkFrameworkEntity:init(t)
    self.theirIP = t.theirIP or "localhost"
    self.port = t.port or 48310
    self:run()
end

function NetworkFrameworkEntity:run()
    self.client, self.servError = socket.connect(self.theirIP, self.port)
    if not self.client then
        self.server, self.servError = socket.bind("*", self.port)
        if self.server then
            print("Network connection info:")
            print(self.server:getsockname())
            
            self.server:settimeout(30)
            self.client, self.servError = self.server:accept()
        end
    end
        
    if self.client then
        self.client:settimeout(0)
    end
end

function NetworkFrameworkEntity:stop()
    if self:isConnected() then
        self.client:close()
        
        if self.server then
            self.server:close()
        end
    end
    
    self.client = nil
    self.server = nil
end

function NetworkFrameworkEntity:isConnected()
    if self.client then
        return true
    end
    
    return false, (self.servError or "Unknown error")
end

function NetworkFrameworkEntity:isServer()
    return self.server and true
end

function NetworkFrameworkEntity:stopIfClosed(e)
    if e == "closed" then
        self.servError = e
        self:stop()
    end
end

function NetworkFrameworkEntity:talker(text)
    if self:isConnected() then
        local b, e = self.client:send(text .. "\n")
        self:stopIfClosed(e)
    end
end

function NetworkFrameworkEntity:listener()
    if self:isConnected() then
        local l, e = self.client:receive()
        self:stopIfClosed(e)
        
        return l
    end
end