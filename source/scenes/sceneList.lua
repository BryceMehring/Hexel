-- TODO: update this to point to the correct scenes

return {
    {title = "Hex Grid",         scene = "scenes/hexGridTest/hexGridTest",  openAnime = "fade",      closeAnime = "fade"},
    {title = "Hex Grid Pattern", scene = "scenes/hexGridTest/hexGridTest",  openAnime = "fade",      closeAnime = "fade", params = {mode = "pattern"}},
    {title = "Single Player",    scene = nil,                               openAnime = "fade",      closeAnime = "fade"},
    {title = "Co-op",            scene = nil,                               openAnime = "crossFade", closeAnime = "crossFade"},
    {title = "Versus",           scene = nil,                               openAnime = "popIn",     closeAnime = "popOut"},
}
