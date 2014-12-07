--------------------------------------------------------------------------------
-- vector.lua - Defines operations for vector operations
--------------------------------------------------------------------------------

vector = flower.class()

function vector:init(t)
    if type(t) == "table" then
        for k, v in ipairs(t) do
            self[k] = v
        end
    else
        t = t or 2 -- default to a 2d vector
        -- Zero out vector
        for i=1, t do
            self[i] = 0
        end
    end
end

function vector:add(other)
    assert(#other == #self, "Vectors are not the same dimension")
    
    local result = vector()
    
    for i, v in ipairs(self) do
        result[i] = v + other[i]
    end

    return result
end

function vector:sub(other)
    return self + other:negate()
end

function vector:negate()
    local result = vector()
    
    for i, v in ipairs(self) do
        result[i] = -v
    end

    return result
end

function vector:mul(other)
    local result = vector()
    local iterTable = type(self) == "table" and self or other
    
    for i, v in ipairs(iterTable) do
        result[i] = v * (type(self) == "number" and self or (type(other) == "number" and other or other[i]))
    end

    return result
end

function vector:equal(other)
    if #other ~= #self then
        return false
    end
    
    for i, v in ipairs(self) do
        if v ~= other[i] then
            return false
        end
    end
    
    return true
end

function vector:unPack()
    return self[1], self[2], self[3], self[4]
end

vector.__interface.__add = vector.add
vector.__interface.__sub = vector.sub
vector.__interface.__unm = vector.negate
vector.__interface.__mul = vector.mul
vector.__interface.__eq  = vector.equal