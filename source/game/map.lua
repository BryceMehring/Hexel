
require "source/pathfinder"
require "source/utilities/vector"
local Towers = require "assets/towers"

Map = flower.class()

function Map:init(t)
    
    -- Copy all data members of the table as member variables
    for k, d in pairs(t) do
        self[k] = d
    end
    
    -- Try to load the map
    if not self:Load() then
        print("Cannot Load Map: " .. self.file)
    end
end

function Map:Load(file)
    self.file = self.file or file
    if not (self.file and io.fileExists(self.file)) then
        return false
    end
    
    self.map = dofile(self.file)
    
    self.width = self.map.width or self.width
    self.height = self.map.height or self.height
    
    self.grid = flower.MapImage(self.texture,
                                self.width,
                                self.height,
                                self.tileWidth,
                                self.tileHeight,
                                self.radius)
                                  
    self.grid:setShape(MOAIGridSpace.HEX_SHAPE)
    self.grid:setLayer(self.layer)
    
    self.grid:setRepeat(false, false)
    self.grid:setPos(0,0)
    
    if type(self.map.tiles) == "table" then
        for i = 1,self.width do
            for j = 1,self.height do
                self.grid.grid:setTile(i, j, self.map.default_tile)
            end
        end
        
        for i, data in ipairs(self.map.tiles) do
            for j, pos in ipairs(data) do
                self.grid.grid:setTile(pos[1], pos[2], i)
            end
        end
    elseif type(self.map.tiles) == "string" then
        -- Load file from stream
        local fileStream = MOAIFileStream.new()
        local success = fileStream:open(self.map.tiles, MOAIFileStream.READ)
        if success then
            self.grid.grid:streamTilesIn(fileStream)
            fileStream:close()
        end
        
        -- TODO: turn the tower types into global variables instead of hardcoding them
        -- Check which tiles are enemy tiles
        self.spawnTiles = {}
        self.targetPosition = {}
        for i = 1,self.width do
            for j = 1,self.height do
                local tile = self.grid.grid:getTile(i, j)
                if tile == 2 then
                    -- this tile is the desination
                    self.targetPosition[1], self.targetPosition[2] = i, j
                elseif tile == 1 then
                    table.insert(self.spawnTiles, {i, j})
                end
            end
        end
    else
        return false
    end
    
    -- TODO: make this a bit more dynamic
    local function validTileCallback(tile)
        return tile == 6 or tile == 2 or tile == 1
    end
    
    -- Find path in the map
    if self:IsPathDynamic() then
        self.path = findPath(self:GetMOAIGrid(), vector{self.targetPosition[1], self.targetPosition[2]}, validTileCallback)
    else
        self.path = self.map.paths[1]
        self.targetPosition = self.path[#self.path]
    end
    
    return true
end

function Map:RandomStartingPosition()
    local startPosition = not self:IsPathDynamic() and self.path[1] or self.startPosition
    if not startPosition then
        local randomIndex = math.random(1, #self.spawnTiles)
        startPosition = self.spawnTiles[randomIndex]
    end
    
    return self:GridToWorldSpace(startPosition)
end

function Map:GridToWorldSpace(pos)
    return vector{self:GetMOAIGrid():getTileLoc(pos[1], pos[2], MOAIGridSpace.TILE_CENTER)}
end

-- Returns true if the path was found using a pathfinder
function Map:IsPathDynamic()
    if self.map.paths then
        return false
    end
    
    return true
end

function Map:GetPath()
    return self.path
end

function Map:GetGrid()
    return self.grid
end

function Map:GetWaves()
    return self.map.waves
end

function Map:GetMOAIGrid()
    return self:GetGrid().grid
end
    