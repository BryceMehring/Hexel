local flower = flower
-- LuaSocket should come with zerobrane
local socket = require("socket")

NetworkFrameworkEntity = flower.class()

function NetworkFrameworkEntity:init(t)
  --self.MyIP = nil
  self.TheirIP = '192.168.1.21'
  port = 8000
  self.talkerConnection = assert(socket.connect(self.TheirIP, port))
  s = assert(socket.bind(self.TheirIP, port))
  self.listenerConnection = assert(s:accept())
end

function talker(text)
	assert(self.talkerConnection:send(text .. "\n"))
end

function listener()
  l, e = self.listenerConnection:receive()
  return l
end