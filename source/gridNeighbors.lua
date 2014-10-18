--------------------------------------------------------------------------------
-- gridNeighbors.lua - Defines functions that retrieve neighbors for tiles on a grid
--------------------------------------------------------------------------------

local neighbors = {
    hex = {
        {
            {x = 0, y = 2},
            {x = 0, y = -2},
            {x = 0, y = -1},
            {x = 0, y = 1},
            {x = 1, y = -1},
            {x = 1, y = 1},
        },
        {
            {x = 0, y = 2},
            {x = 0, y = -2},
            {x = 0, y = -1},
            {x = 0, y = 1},
            {x = -1, y = -1},
            {x = -1, y = 1}
        }
    }
}

-- Return a list of offsets for the tiles neighbors
function getHexNeighbors(pos)
    local parity = pos.y % 2 == 0 and 1 or 2
    return neighbors.hex[parity]
end