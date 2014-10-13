local _oldRequire = require
require = function(path, ...)
    return _oldRequire("source." .. path:gsub("%/", "."), ...)
end

-- Call this to enable debugging, kind of a hack just for right now
-- TODO: fix hack
function enableDebugging()
    _oldRequire('mobdebug').on()
end

require "main"