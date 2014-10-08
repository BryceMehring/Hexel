
local _oldRequire = require
require = function(path, ...)
    return _oldRequire("source/" .. path:gsub("%/", "."), ...)
end

require "main"