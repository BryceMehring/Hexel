local flower = flower
-- LuaSocket should come with zerobrane
local socket = require("socket")

NetworkFrameworkEntity = flower.class()

function NetworkFrameworkEntity:init(t)
    self.tcp = socket.tcp()
    self.tcp:settimeout(2)
    --self.MyIP = nil
    self.TheirIP = '192.168.1.21'
    port = 8000
    self.talkerConnection = self.tcp:connect(self.TheirIP, port)
    if self.talkerConnection then
        s = assert(socket.bind(self.TheirIP, port))
        self.listenerConnection = assert(s:accept())
    end
end

function NetworkFrameworkEntity:isConnected()
    return self.talkerConnection and true or false
end

function NetworkFrameworkEntity:talker(text)
    if self.talkerConnection then
        assert(self.talkerConnection:send(text .. "\n"))
    end
end

function NetworkFrameworkEntity:listener()
    l, e = self.listenerConnection:receive()
    return l
end