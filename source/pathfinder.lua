
-- TODO: cleanup and add comments

require "source/gridNeighbors"
require "source/utilities/vector"
require "source/utilities/queue"

local function posToKey(gridWidth, pos)
    return pos[1] + pos[2] * (gridWidth + 1)
end

function getPathDestination(grid, pos, path)
    local gridWidth = grid:getSize()
    local key = posToKey(gridWidth, vector{grid:locToCoord(pos[1], pos[2])})
    local node = path[key]
    if node then
        local parent = path[key].parent
        return parent and vector{grid:getTileLoc(parent.position[1], parent.position[2], MOAIGridSpace.TILE_CENTER)}
    end
end

-- Finds the shortest path from from every node on the map to the targetPosition
function findPath(grid, targetPosition, validTileCallback)
    local width, height = grid:getSize()
    
    local function ValidTile(pos)
        return pos[1] >= 1 and pos[1] <= width and
               pos[2] >= 1 and pos[2] <= height and
               validTileCallback(grid:getTile(pos[1], pos[2]))
    end
    
    if not ValidTile(targetPosition) then
        return false
    end
    
    local visited = {}
    local list = Queue()
    
    list:push({position = targetPosition, parent = nil})
    visited[posToKey(width, targetPosition)] = list:front()
    
    while not list:empty() do
        -- Pop the front node from the queue
        local currentNode = list:front()
        list:pop()
        
        local directions = getHexNeighbors(currentNode.position)
        for i, dir in ipairs(directions) do
            local newPos = currentNode.position + dir
            local key = posToKey(width, newPos)
            if ValidTile(newPos) and not visited[key] then
                local newNode = {position = newPos, parent = currentNode}
                list:push(newNode)
                visited[key] = newNode
            end
        end
    end
    
    return visited
end