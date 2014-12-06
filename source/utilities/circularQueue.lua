require "source/utilities/queue"

-- TODO: is this a good name for this class?
CircularQueue = flower.class(Queue)

function CircularQueue:init(size, ...)
    Queue.init(self, ...)
    
    self.maxSize = size
end

function CircularQueue:push(...)
    Queue.push(self, ...)
    
    if self:size() > self.maxSize then
        self:pop()
    end
end