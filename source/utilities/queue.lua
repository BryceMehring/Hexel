Queue = flower.class()

local table = table

function Queue:init(t)
    if type(t) == "table" then
        self.queue = flower.deepCopy(t)
    else
        self.queue = {}
    end
end

function Queue:pop()
    table.remove(self.queue, 1)
end

function Queue:push(data)
    table.insert(self.queue, data)
end

function Queue:front()
    return self.queue[1]
end

function Queue:empty()
    return self:size() <= 0
end

function Queue:size()
    return #self.queue
end