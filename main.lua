local _oldRequire = require
require = function(path, ...)
    return _oldRequire(path:gsub("%/", "."), ...)
end

-- Call this to enable debugging
function enableDebugging()
    require('mobdebug').on()
end

require "source/main" 