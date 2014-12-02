-- TODO: update this to point to the correct scenes
require "source/gameConfig"

local networkingScene = Configuration("Enable Networking") and 'source/scenes/multiPlayer'

return {
    {title = "Single Player",    scene = 'source/scenes/mapSelect',            openAnime = "fade", closeAnime = "fade"},
    {title = "Co-op",            scene = nil,                                  openAnime = "fade", closeAnime = "fade"},
    {title = "Versus",           scene = networkingScene,                      openAnime = "fade", closeAnime = "fade"},
    {title = "Map Editor",       scene = "source/scenes/mapEditor",            openAnime = "fade", closeAnime = "fade"},
}
