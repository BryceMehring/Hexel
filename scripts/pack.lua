-- http://getmoai.com/wiki/index.php?title=Concatenate_your_Lua_source_tree
-- Usage: $ lua pack.lua path/to/your/source/tree > out.lua
 
args = {...}
--require"luarocks.loader"
fs = require"lfs"
files = {}

args[1] = args[1] or "../"

root = args[1]:gsub( "/$", "" )
              :gsub( "\\$", "" )
 
function scandir (root, path)
-- adapted from http://keplerproject.github.com/luafilesystem/examples.html
    path = path or ""
    for file in fs.dir( root..path ) do
        if file ~= "." and file ~= ".." and file ~= "scripts" then
            local f = path..'/'..file
            local attr = lfs.attributes( root..f )
            assert (type( attr ) == "table")
            if attr.mode == "directory" then
                scandir( root, f )
            else
              if file:find"%.lua$" then
                hndl = (f:gsub( "%.lua$", "" )
                                 :gsub( "/", "." )
                                 :gsub( "\\", "." )
                                 :gsub( "^%.", "" )
                               ):gsub( "%.init$", "" )
                files[hndl] = io.open( root..f ):read"*a"
              end
            end
        end
    end
end
 
scandir( root )
 
acc={}
 
local wrapper = { "\n--------------------------------------\npackage.preload['"
                , nil, "'] = function (...)\n", nil, "\nend\n" }
for k,v in pairs( files ) do
  wrapper[2], wrapper[4] = k, v
  table.insert( acc, table.concat(wrapper) )
end
 
table.insert(acc, [[
-----------------------------------------------
 
do
  if not package.__loadfile then
    local original_loadfile = loadfile
    local function lf (file)
      local hndl = file:gsub( "%.lua$", "" )
                       :gsub( "/", "." )
                       :gsub( "\\", "." )
                       :gsub( "%.init$", "" )
      return package.preload[hndl] or original_loadfile( name )
    end
 
    function dofile (name)
      return lf( name )()
    end
 
    loadfile, package.__loadfile = lf, loadfile
  end
end
]])
if files.main then table.insert( acc, '\ndofile"main.lua"' ) end

local file = io.open("singleFile.lua", "w")
file:write(table.concat( acc ))
file:close()
