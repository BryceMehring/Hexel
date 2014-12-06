require "source/utilities/queue"

LimitedQueue = flower.class(Queue)

function LimitedQueue:init(size, ...)
    Queue.init(self, ...)
    
    self.maxSize = size
end

function LimitedQueue:push(...)
    Queue.push(self, ...)
    
    if self:size() > self.maxSize then
        self:pop()
    end
end