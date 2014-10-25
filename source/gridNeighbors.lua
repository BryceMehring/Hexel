--------------------------------------------------------------------------------
-- gridNeighbors.lua - Defines functions that retrieve neighbors for tiles on a grid
--------------------------------------------------------------------------------

local neighbors = {
    hex = {
        {
            {0, 2},
            {0, -2},
            {0, -1},
            {0, 1},
            {1, -1},
            {1, 1},
        },
        {
            {0, 2},
            {0, -2},
            {0, -1},
            {0, 1},
            {-1, -1},
            {-1, 1}
        }
    }
}

-- Return a list of offsets for the tiles neighbors
function getHexNeighbors(pos)
    local parity = pos[2] % 2 == 0 and 1 or 2
    return neighbors.hex[parity]
end