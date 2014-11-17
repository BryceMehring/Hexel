--------------------------------------------------------------------------------
-- io.lua - Contains functions that extend the default io functions
--------------------------------------------------------------------------------

require "lfs"

-- source: http://stackoverflow.com/questions/4990990/lua-check-if-a-file-exists
function io.fileExists(name)
    local f = io.open(name,"r")
    if f ~= nil then io.close(f) return true else return false end
end

function io.files(dir)
    local files = {}
    
    for file in lfs.dir(dir) do
        local fullPath = dir .. file
        if lfs.attributes(fullPath,"mode") == "file" then
            table.insert(files, fullPath)
        end
    end
 
    
    return files
end