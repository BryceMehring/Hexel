
_oldRequire = require
require = function(path, ...)
    return _oldRequire("source/" .. path)
end

require "main"