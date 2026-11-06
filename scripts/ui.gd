extends Control
## Mobile multi-touch buttons and accessible HUD for Emberwood.
const WHITE := Color("#f4e8c8")
const MUTE := Color("#afc7b7")
const PANEL := Color(0.075, 0.15, 0.15, 0.91)
var held: Dictionary = {}
var buttons: Dictionary = {
    "move_up": Vector2(142, 355),
    "move_down": Vector2(142, 469),
    "move_left": Vector2(84, 412),
    "move_right": Vector2(200, 412),
    "attack": Vector2(861, 417),
    "dodge": Vector2(741, 468),
    "potion": Vector2(768, 351)
}

@onready var game: Node2D = $"../../Game"

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    get_viewport().size_changed.connect(queue_redraw)
    queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and (game.dead or game.finished):
            if event.position.distance_to(Vector2(480, 355)) < 160.0:
                game._reset()
                get_viewport().set_input_as_handled()
                return
        _update_pointer(event.index, event.position, event.pressed)
    elif event is InputEventScreenDrag:
        _update_pointer(event.index, event.position, true)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and (game.dead or game.finished) and event.position.distance_to(Vector2(480, 355)) < 160.0:
            game._reset()
            return
        _update_pointer(-1, event.position, event.pressed)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        _update_pointer(-1, event.position, true)

func _update_pointer(id: int, pos: Vector2, down: bool) -> void:
    var old: String = held.get(id, "")
    var next := ""
    if down:
        for key in buttons.keys():
            var center: Vector2 = buttons[key]
            var radius := 61.0 if key == "attack" else 43.0
            if pos.distance_to(center) < radius:
                next = key
                break
    if old == next:
        return
    held.erase(id)
    if next != "":
        held[id] = next
    if old != "" and not held.values().has(old):
        Input.action_release(old)
    if next != "":
        Input.action_press(next)
    queue_redraw()

func _txt(s: String, at: Vector2, size: int = 20, color: Color = WHITE) -> void:
    draw_string(ThemeDB.fallback_font, at, s, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _panel(r: Rect2) -> void:
    draw_rect(r.grow(3), Color("#132b2a"))
    draw_rect(r, PANEL)
    draw_rect(Rect2(r.position, Vector2(r.size.x, 3)), Color("#cdac73"))

func _draw() -> void:
    # Upper HUD with strong contrast.
    _panel(Rect2(18, 17, 301, 79))
    _txt("EMBERWOOD  /  THE MOON SHRINE", Vector2(29, 40), 16)
    draw_rect(Rect2(30, 52, 239, 18), Color("#442e37"))
    draw_rect(Rect2(32, 54, 235.0 * float(game.hp) / float(game.max_hp), 14), Color("#d36e66"))
    _txt("%d / %d" % [game.hp, game.max_hp], Vector2(98, 67), 13)
    _txt("LV %d   DMG %d" % [game.level, game.power], Vector2(30, 87), 14, MUTE)

    _panel(Rect2(665, 17, 276, 81))
    if game.boss_spawned and not game.finished:
        _txt("GUARDIAN AWAKE", Vector2(682, 44), 20, Color("#efbca0"))
        _txt("DEFEAT THE SHRINE KEEPER", Vector2(682, 72), 15)
    elif game.finished:
        _txt("FOREST SAVED!", Vector2(685, 48), 20, Color("#ffe1a0"))
    else:
        _txt("QUEST  /  01", Vector2(681, 44), 15, MUTE)
        _txt("SLIMES: %d / 8" % game.kills, Vector2(681, 75), 24)

    if game.message_time > 0.0:
        _panel(Rect2(316, 110, 347, 53))
        _txt(game.message, Vector2(329, 143), 15, WHITE)

    # Arcade buttons intentionally keep the middle of the map unobstructed.
    _key("move_up", "^", 36.0, Color("#3d685f"))
    _key("move_down", "v", 36.0, Color("#3d685f"))
    _key("move_left", "<", 36.0, Color("#3d685f"))
    _key("move_right", ">", 36.0, Color("#3d685f"))
    _key("attack", "ATK", 56.0, Color("#bb6755"))
    _key("dodge", "DASH", 40.0, Color("#4e7c8a"))
    _key("potion", "+", 38.0, Color("#488b76"))
    _txt("x%d" % game.elixirs, Vector2(797, 359), 18, WHITE)

    if game.dead or game.finished:
        draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color(0.025, 0.08, 0.08, 0.78))
        _panel(Rect2(199, 167, 562, 246))
        if game.finished:
            _txt("THE FOREST IS FREE", Vector2(271, 234), 38, Color("#f4d494"))
            _txt("You saved the Moon Shrine.", Vector2(338, 283), 20)
        else:
            _txt("THE FOREST CLAIMED YOU", Vector2(248, 234), 31, Color("#ecc4a7"))
            _txt("Drink a potion and dodge to survive.", Vector2(305, 283), 18)
        draw_rect(Rect2(342, 324, 278, 52), Color("#b17c4f"))
        _txt("PLAY AGAIN", Vector2(403, 358), 23, Color("#203b38"))

func _key(action: String, title: String, radius: float, base_color: Color) -> void:
    var p: Vector2 = buttons[action]
    var on: bool = held.values().has(action)
    draw_circle(p + Vector2(0, 5), radius + 6, Color(0.06, 0.14, 0.13, 0.8))
    draw_circle(p, radius + 2, Color("#d6c6a0"))
    var c := base_color.lightened(0.18) if on else base_color
    c.a = 0.92
    draw_circle(p, radius - 3, c)
    var size := 21 if title.length() < 4 else 14
    var text_width := float(title.length() * size) * 0.56
    _txt(title, p + Vector2(-text_width * 0.5, float(size) * 0.34), size, WHITE)
