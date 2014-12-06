require "source/utilities/queue"

-- TODO: is this a good name for this class?
CircularQueue = flower.class(Queue)

function CircularQueue:init(size, ...)
    Queue.init(self, ...)
    
    self.maxSize = size
end

function CircularQueue:push(...)
    Queue.push(self, ...)
    
    while self:size() > self.maxSize do
        self:pop()
    end
end