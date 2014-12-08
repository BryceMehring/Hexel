-- TODO: update this to point to the correct scenes
require "source/gameConfig"

local networkingMultiPlayerScene
if not Configuration("Disable Networking") then
    networkingMultiPlayerScene = 'source/scenes/multiPlayer'
end

return {
    {title = "Single Player",    scene = 'source/scenes/mapSelect',            openAnime = "fade", closeAnime = "fade"},
    {title = "Co-op",            scene = networkingMultiPlayerScene,           openAnime = "fade", closeAnime = "fade"},
    {title = "Server",           scene = 'source/scenes/serverScene',          openAnime = "fade", closeAnime = "fade"},
    {title = "Map Editor",       scene = "source/scenes/mapEditor",            openAnime = "fade", closeAnime = "fade"},
}
