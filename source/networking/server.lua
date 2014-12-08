local flower = flower
-- LuaSocket should come with zerobrane
local socket = require("socket")

Server = flower.class()

function Server:init(t)
    enableDebugging()
    self.port = t.port or 48310
    self.server, self.servError = socket.bind("*", self.port)
    
    if self.server then
        self.client = {}
        self.server:settimeout(0)
        local serverThread = MOAIThread.new()
        serverThread:run(function()
            self:run()
            coroutine.yield()
        end)
        print("Network connection info:")
        print(self.server:getsockname())
    end
end

function Server:run()
    enableDebugging()

    if self.server then
        local set = {self.server}

        local readable = socket.select(set)
        for i, input in ipairs(readable) do
            input:settimeout(0)
            local new = input:accept()
            if new then
                new:settimeout(0)
                self.client[new] = new
                self.connected = true
            end
        end

--        local newClient = self.server:accept()
--        table.insert(self.client, newClient)

        --print(#tempClients .. " client(s) connected")
    end
end

function Server:stop()
    if self:isConnected() then
        for client, _ in pairs(self.client) do
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
    if self.connected then
        return self.connected
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
    enableDebugging()
    if self:isConnected() then
        for client, _ in pairs(self.client) do
            local b, e = client:send(text .. "\n")
        end
        --self:stopIfClosed(e)
    end
end
