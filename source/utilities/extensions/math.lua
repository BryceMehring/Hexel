--------------------------------------------------------------------------------
-- math.lua - Contains functions that extend the default math functions
--------------------------------------------------------------------------------

---
-- Generates a list of random numbers
-- @param min random number to generate
-- @param max random number to generate
-- @param the number of random numbers to generate
-- @return a list of n random numbers
function math.generateRandomNumbers(min, max, n)
    local numberList = {}
    for i=1, n do
        table.insert(numberList, math.random(min, max))
    end
    
    return numberList
end