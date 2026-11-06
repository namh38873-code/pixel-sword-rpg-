extends Node2D
## Hand-painted-in-code pixel-style overworld. No third-party assets.
const MAP_W := 1920
const MAP_H := 1344
const TILE := 48
const GROUND := Color("#335849")
const GRASS_A := Color("#396b50")
const GRASS_B := Color("#3d7053")
const GRASS_C := Color("#477959")
const PATH_EDGE := Color("#856846")
const PATH := Color("#c7a46a")
const PATH_LIT := Color("#d3b478")
const DARK := Color("#1c3430")
const WATER := Color("#245d70")
var trees: Array[Vector2] = []
var rocks: Array[Vector2] = []
var flowers: Array[Vector2] = []

func _ready() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 573920
    for i in range(185):
        var p := Vector2(float(rng.randi_range(60, MAP_W - 60)), float(rng.randi_range(75, MAP_H - 65)))
        if _on_route(p) or p.distance_to(Vector2(320, 940)) < 245.0 or p.distance_to(Vector2(1535, 325)) < 225.0:
            continue
        if i % 5 == 0:
            rocks.append(p)
        else:
            trees.append(p)
    for i in range(170):
        var p := Vector2(float(rng.randi_range(26, MAP_W - 26)), float(rng.randi_range(26, MAP_H - 26)))
        if not _on_route(p):
            flowers.append(p)
    queue_redraw()

func _on_route(p: Vector2) -> bool:
    return (p.y > 825 and p.y < 1015 and p.x > 170 and p.x < 910) or (p.x > 715 and p.x < 965 and p.y > 430 and p.y < 1010) or (p.y > 425 and p.y < 625 and p.x > 735 and p.x < 1590) or (p.x > 1400 and p.x < 1630 and p.y > 285 and p.y < 625)

func blocked(p: Vector2) -> bool:
    if p.x < 35 or p.y < 45 or p.x > MAP_W - 35 or p.y > MAP_H - 35:
        return true
    for t in trees:
        if p.distance_squared_to(t + Vector2(0, 12)) < 900.0:
            return true
    for r in rocks:
        if p.distance_squared_to(r) < 700.0:
            return true
    if p.x > 169 and p.x < 366 and p.y > 705 and p.y < 840:
        return true
    return false

func _draw() -> void:
    draw_rect(Rect2(0, 0, MAP_W, MAP_H), GROUND)
    for ty in range(28):
        for tx in range(40):
            var x := tx * TILE
            var y := ty * TILE
            var n := (tx * 139 + ty * 73 + tx * ty * 19) % 11
            var shade: Color = GRASS_A if n < 4 else (GRASS_B if n < 9 else GRASS_C)
            draw_rect(Rect2(x, y, TILE, TILE), shade)
            draw_rect(Rect2(x + 6 + n, y + 11, 5, 3), Color("#62966a"))
            draw_rect(Rect2(x + 28, y + 32 - n, 3, 7), Color("#286047"))
            if n % 3 == 0:
                draw_rect(Rect2(x + 37, y + 9, 4, 4), Color("#73966b"))
    # Clearly readable winding road.
    _road(Rect2(165, 856, 745, 122))
    _road(Rect2(762, 479, 130, 450))
    _road(Rect2(805, 473, 731, 121))
    _road(Rect2(1458, 319, 125, 234))
    # Training courtyard.
    draw_rect(Rect2(215, 870, 248, 173), Color("#876c49"))
    draw_rect(Rect2(226, 879, 228, 154), Color("#c3a774"))
    for i in range(12):
        draw_rect(Rect2(238 + (i * 17) % 209, 896 + (i * 41) % 121, 13, 5), Color("#aa8556"))
    # Pond in western woods.
    draw_rect(Rect2(305, 274, 320, 168), Color("#1e4d52"))
    draw_rect(Rect2(318, 290, 294, 135), WATER)
    for i in range(15):
        draw_rect(Rect2(331 + (i * 41) % 258, 309 + (i * 21) % 106, 28, 4), Color("#4a91a0"))
    # Stone shrine at the far end of the route.
    draw_rect(Rect2(1368, 203, 336, 272), Color("#233a38"))
    draw_rect(Rect2(1382, 220, 306, 237), Color("#707c72"))
    for i in range(7):
        draw_rect(Rect2(1401 + i * 39, 224, 3, 230), Color("#637166"))
    for j in range(6):
        draw_rect(Rect2(1388, 240 + j * 39, 291, 3), Color("#58685c"))
    draw_rect(Rect2(1420, 255, 228, 151), Color("#859183"))
    draw_rect(Rect2(1440, 269, 187, 116), Color("#536d60"))
    draw_rect(Rect2(1460, 290, 147, 78), Color("#314d4c"))
    draw_rect(Rect2(1513, 286, 40, 85), Color("#bc8d63"))
    draw_rect(Rect2(1520, 292, 25, 65), Color("#dec087"))
    # Ruin pillars, torches.
    for x in [1398, 1638]:
        draw_rect(Rect2(x, 215, 31, 119), Color("#414f4b"))
        draw_rect(Rect2(x - 4, 212, 39, 18), Color("#9eab96"))
        draw_rect(Rect2(x + 7, 220, 7, 96), Color("#788b7d"))
        draw_rect(Rect2(x - 2, 322, 34, 10), Color("#283b39"))
    # Cabin at the start.
    _cabin(Vector2(170, 704))
    # A few fence lines around camp.
    for x in range(165, 678, 47):
        if x > 345 and x < 510:
            continue
        _fence(Vector2(x, 1050))
    _sign(Vector2(651, 819))
    _sign(Vector2(1210, 423))
    # Road pebbles and marks.
    for i in range(96):
        var p := Vector2(180 + (i * 173) % 1380, 480 + (i * 101) % 490)
        if _on_route(p):
            draw_rect(Rect2(p, Vector2(6 + i % 6, 3)), Color("#a78a5c"))
    # Decorative grasses, stones and trees.
    for f in flowers:
        draw_rect(Rect2(f.x - 2, f.y - 4, 5, 7), Color("#a9c573"))
        draw_rect(Rect2(f.x, f.y - 8, 4, 4), Color("#f3c58f") if int(f.x) % 3 == 0 else Color("#d0a2bc"))
    for r in rocks:
        _rock(r)
    for t in trees:
        _tree(t)
    # Outer border.
    draw_rect(Rect2(0, 0, MAP_W, 30), DARK)
    draw_rect(Rect2(0, MAP_H - 30, MAP_W, 30), DARK)
    draw_rect(Rect2(0, 0, 30, MAP_H), DARK)
    draw_rect(Rect2(MAP_W - 30, 0, 30, MAP_H), DARK)

func _road(r: Rect2) -> void:
    draw_rect(r.grow(10), PATH_EDGE)
    draw_rect(r, PATH)
    var n := int(r.size.x / 38)
    for i in range(n):
        var xx := r.position.x + i * 38 + 8
        draw_rect(Rect2(xx, r.position.y + 7 + i % 4 * 6, 15, 4), PATH_LIT)
        draw_rect(Rect2(xx + 10, r.end.y - 18 - i % 3 * 7, 9, 4), Color("#ad8957"))

func _tree(p: Vector2) -> void:
    draw_rect(Rect2(p.x - 25, p.y + 17, 54, 12), Color("#224639"))
    draw_rect(Rect2(p.x - 8, p.y - 13, 17, 46), Color("#5a4035"))
    draw_rect(Rect2(p.x - 4, p.y - 6, 6, 34), Color("#95734b"))
    draw_rect(Rect2(p.x - 29, p.y - 50, 58, 49), Color("#193e38"))
    draw_rect(Rect2(p.x - 24, p.y - 63, 48, 52), Color("#28734f"))
    draw_rect(Rect2(p.x - 34, p.y - 39, 68, 21), Color("#226345"))
    draw_rect(Rect2(p.x - 20, p.y - 57, 23, 10), Color("#4a9560"))
    draw_rect(Rect2(p.x + 4, p.y - 45, 18, 9), Color("#4c9963"))
    draw_rect(Rect2(p.x - 27, p.y - 25, 15, 6), Color("#3e865b"))

func _rock(p: Vector2) -> void:
    draw_rect(Rect2(p.x - 25, p.y + 10, 48, 9), Color("#294b40"))
    draw_rect(Rect2(p.x - 21, p.y - 12, 42, 27), Color("#677f72"))
    draw_rect(Rect2(p.x - 13, p.y - 21, 29, 14), Color("#899b84"))
    draw_rect(Rect2(p.x - 14, p.y - 16, 17, 7), Color("#b1b89a"))
    draw_rect(Rect2(p.x + 10, p.y + 6, 10, 8), Color("#445e55"))

func _cabin(p: Vector2) -> void:
    draw_rect(Rect2(p.x - 6, p.y + 106, 209, 24), Color("#254b3b"))
    draw_rect(Rect2(p.x, p.y + 36, 195, 92), Color("#956d4a"))
    for i in range(7):
        draw_rect(Rect2(p.x + i * 28, p.y + 47, 4, 75), Color("#6c4e38"))
    draw_rect(Rect2(p.x - 14, p.y + 18, 224, 28), Color("#563b43"))
    draw_rect(Rect2(p.x + 1, p.y - 4, 192, 42), Color("#87514d"))
    draw_rect(Rect2(p.x + 21, p.y - 16, 153, 20), Color("#ac6953"))
    draw_rect(Rect2(p.x + 73, p.y + 73, 51, 55), Color("#493e35"))
    draw_rect(Rect2(p.x + 80, p.y + 78, 37, 51), Color("#68492e"))
    draw_rect(Rect2(p.x + 104, p.y + 104, 6, 7), Color("#e9b776"))
    draw_rect(Rect2(p.x + 14, p.y + 63, 39, 32), Color("#d5ad73"))
    draw_rect(Rect2(p.x + 19, p.y + 68, 29, 22), Color("#6bc0bf"))

func _fence(p: Vector2) -> void:
    draw_rect(Rect2(p.x, p.y + 8, 46, 8), Color("#503c30"))
    draw_rect(Rect2(p.x + 4, p.y - 16, 11, 40), Color("#ba8853"))
    draw_rect(Rect2(p.x + 31, p.y - 16, 11, 40), Color("#ba8853"))
    draw_rect(Rect2(p.x + 3, p.y - 20, 13, 7), Color("#dec08b"))
    draw_rect(Rect2(p.x + 30, p.y - 20, 13, 7), Color("#dec08b"))

func _sign(p: Vector2) -> void:
    draw_rect(Rect2(p.x + 19, p.y + 6, 10, 46), Color("#6e5037"))
    draw_rect(Rect2(p.x, p.y - 9, 50, 34), Color("#4c352d"))
    draw_rect(Rect2(p.x + 4, p.y - 5, 42, 25), Color("#c19760"))
    draw_rect(Rect2(p.x + 13, p.y + 1, 20, 4), Color("#72533a"))
    draw_rect(Rect2(p.x + 20, p.y + 10, 17, 4), Color("#72533a"))
