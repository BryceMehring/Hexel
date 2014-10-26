--------------------------------------------------------------------------------
-- math.lua - Contains functions that extend the default math functions
--------------------------------------------------------------------------------

function math.randomFloatBetween(min, max)
    return math.random() * (max - min) + min
end

---
-- Generates a list of random floating point numbers
-- @param min random number to generate
-- @param max random number to generate
-- @param the number of random numbers to generate
-- @return a list of n random numbers
function math.generateRandomNumbers(min, max, n)
    local numberList = {}
    for i=1, n do
        table.insert(numberList, math.randomFloatBetween(min, max))
    end
    
    return numberList
end

---
-- Rearranges the elements of the list randomly.
-- @param the table to be randomized
function math.shuffle(list)
    if type(list) ~= "table" then
        return
    end
    
    for i=1, #list do
        local randomElement = math.random(1, #list)
        list[i], list[randomElement] = list[randomElement], list[i]
    end
end

-- Rearranges the elements in list randomly.
-- @param the table to be randomized
-- @return randomized copy of the list
function math.shuffleCopy(list)
    local listCopy = flower.table.copy(list)
    math.shuffle(listCopy)
    return listCopy
end

function math.clamp(x, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, x))
end