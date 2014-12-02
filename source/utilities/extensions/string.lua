--------------------------------------------------------------------------------
-- string.lua - Contains functions that extend the default string functions
--------------------------------------------------------------------------------

function string.charSafe(c)
    return c >= 0 and c < 256 and string.char(c)
end