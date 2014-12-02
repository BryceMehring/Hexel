-------------------------------------------------------------------------------
-- Configuration: developer settings to help speed up development.
--                no values should ever be pushed as active
--------------------------------------------------------------------------------

_Configuration = {
    --["Disable Sound"] = true,
    --["Disable Networking"] = true,
}
    
function Configuration(key)
    return _Configuration and _Configuration[key]
end