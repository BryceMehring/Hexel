--------------------------------------------------------------------------------
-- io.lua - Contains functions that extend the default io functions
--------------------------------------------------------------------------------

-- source: http://stackoverflow.com/questions/4990990/lua-check-if-a-file-exists
function io.fileExists(name)
    local f = io.open(name,"r")
    if f ~= nil then io.close(f) return true else return false end
end