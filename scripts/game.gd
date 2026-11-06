extends Node2D
## Emberwood - compact, fully playable sword-RPG adventure.
## Uses original procedurally drawn pixel-style art; Godot 4.7 compatible.

const PLAYER_START := Vector2(338, 937)
const MAX_SLIMES := 8
const SLIME_SPAWNS: Array[Vector2] = [
    Vector2(532, 911), Vector2(682, 912), Vector2(821, 771),
    Vector2(843, 628), Vector2(1007, 518), Vector2(1168, 529),
    Vector2(1339, 530), Vector2(1515, 540)
]

@onready var world: Node2D = $"../World"
@onready var camera: Camera2D = $Camera2D
@onready var interface: Control = $"../UILayer/UI"

var player_pos: Vector2 = PLAYER_START
var facing: Vector2 = Vector2.DOWN
var hp: int = 100
var max_hp: int = 100
var power: int = 18
var level: int = 1
var experience: int = 0
var elixirs: int = 3
var kills: int = 0
var enemies: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var boss_spawned: bool = false
var finished: bool = false
var dead: bool = false
var time_passed: float = 0.0
var attack_time: float = 0.0
var attack_cd: float = 0.0
var dodge_time: float = 0.0
var dodge_cd: float = 0.0
var invincibility: float = 0.0
var message: String = "Follow the golden road to the Moon Shrine!"
var message_time: float = 4.0
var effects: Array[Dictionary] = []

func _enter_tree() -> void:
    _make_input("move_up", [KEY_W, KEY_UP])
    _make_input("move_down", [KEY_S, KEY_DOWN])
    _make_input("move_left", [KEY_A, KEY_LEFT])
    _make_input("move_right", [KEY_D, KEY_RIGHT])
    _make_input("attack", [KEY_J, KEY_SPACE])
    _make_input("dodge", [KEY_K, KEY_SHIFT])
    _make_input("potion", [KEY_H, KEY_E])

func _make_input(action: StringName, keys: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    for code in keys:
        var event := InputEventKey.new()
        event.physical_keycode = code
        InputMap.action_add_event(action, event)

func _ready() -> void:
    camera.make_current()
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = 1920
    camera.limit_bottom = 1344
    _reset()

func _reset() -> void:
    player_pos = PLAYER_START
    facing = Vector2.DOWN
    hp = 100
    max_hp = 100
    power = 18
    level = 1
    experience = 0
    elixirs = 3
    kills = 0
    boss_spawned = false
    finished = false
    dead = false
    time_passed = 0.0
    attack_time = 0.0
    attack_cd = 0.0
    dodge_time = 0.0
    dodge_cd = 0.0
    invincibility = 0.0
    enemies.clear()
    effects.clear()
    pickups = [
        {"pos": Vector2(501, 939), "kind": "potion"},
        {"pos": Vector2(1007, 602), "kind": "potion"},
        {"pos": Vector2(1417, 591), "kind": "potion"}
    ]
    for p in SLIME_SPAWNS:
        enemies.append(_enemy(p, false))
    _say("The Moon Shrine is cursed. Defeat 8 slimes!", 5.0)
    camera.position = player_pos
    queue_redraw()
    interface.queue_redraw()

func _enemy(p: Vector2, boss: bool) -> Dictionary:
    return {
        "pos": p,
        "hp": 165 if boss else 35,
        "max": 165 if boss else 35,
        "speed": 63.0 if boss else 76.0,
        "boss": boss,
        "time": float(int(p.x) % 7),
        "hit": 0.0,
        "attack": 0.0,
        "knock": Vector2.ZERO
    }

func _say(s: String, seconds: float = 3.0) -> void:
    message = s
    message_time = seconds

func _process(delta: float) -> void:
    delta = minf(delta, 0.06)
    time_passed += delta
    message_time = maxf(0.0, message_time - delta)
    if (dead or finished) and Input.is_action_just_pressed("attack"):
        _reset()
        return
    if dead or finished:
        interface.queue_redraw()
        return

    attack_cd = maxf(0.0, attack_cd - delta)
    attack_time = maxf(0.0, attack_time - delta)
    dodge_cd = maxf(0.0, dodge_cd - delta)
    dodge_time = maxf(0.0, dodge_time - delta)
    invincibility = maxf(0.0, invincibility - delta)

    var direction := Vector2.ZERO
    if Input.is_action_pressed("move_left"):
        direction = Vector2.LEFT
    elif Input.is_action_pressed("move_right"):
        direction = Vector2.RIGHT
    elif Input.is_action_pressed("move_up"):
        direction = Vector2.UP
    elif Input.is_action_pressed("move_down"):
        direction = Vector2.DOWN
    if direction != Vector2.ZERO and dodge_time <= 0.0:
        facing = direction

    if Input.is_action_just_pressed("dodge") and dodge_cd <= 0.0:
        dodge_time = 0.22
        dodge_cd = 1.2
        invincibility = maxf(invincibility, 0.24)
        _spark(player_pos, Color("#9ee8c2"), 5)
    if Input.is_action_just_pressed("attack") and attack_cd <= 0.0:
        _swing()
    if Input.is_action_just_pressed("potion") and elixirs > 0 and hp < max_hp:
        elixirs -= 1
        hp = mini(max_hp, hp + 40)
        _spark(player_pos, Color("#9be9db"), 10)
        _say("Healing potion +40 HP", 1.7)

    var speed := 155.0
    if dodge_time > 0.0:
        direction = facing
        speed = 375.0
    elif attack_time > 0.0:
        speed = 93.0
    if direction != Vector2.ZERO:
        _move_player(direction * speed * delta)

    for p in pickups.duplicate():
        if player_pos.distance_to(p["pos"]) < 35.0:
            elixirs = mini(5, elixirs + 1)
            _spark(p["pos"], Color("#8bdecb"), 7)
            pickups.erase(p)
            _say("Found a healing potion!", 1.8)

    _move_enemies(delta)
    for e in effects.duplicate():
        e["life"] = float(e["life"]) - delta
        if e["life"] <= 0.0:
            effects.erase(e)

    # Camera smoothing, clamped by Camera2D limits.
    camera.position = camera.position.lerp(player_pos, minf(1.0, 5.5 * delta))
    queue_redraw()
    interface.queue_redraw()

func _move_player(change: Vector2) -> void:
    var test_x := player_pos + Vector2(change.x, 0.0)
    if not world.blocked(test_x):
        player_pos.x = test_x.x
    var test_y := player_pos + Vector2(0.0, change.y)
    if not world.blocked(test_y):
        player_pos.y = test_y.y

func _move_enemies(delta: float) -> void:
    for e in enemies:
        e["time"] = float(e["time"]) + delta
        e["hit"] = maxf(0.0, float(e["hit"]) - delta)
        e["attack"] = maxf(0.0, float(e["attack"]) - delta)
        var pos: Vector2 = e["pos"]
        var toward := player_pos - pos
        var dist := toward.length()
        var boss: bool = e["boss"]
        var sense: float = 440.0 if boss else 265.0
        var min_dist: float = 55.0 if boss else 36.0
        if dist < sense and dist > min_dist and dodge_time <= 0.0:
            var step := toward.normalized() * float(e["speed"]) * delta
            if not world.blocked(pos + step):
                e["pos"] = pos + step
        if dist < (75.0 if boss else 42.0) and float(e["attack"]) <= 0.0:
            e["attack"] = 1.0 if boss else 1.25
            _hurt(18 if boss else 9, pos)

func _hurt(damage: int, origin: Vector2) -> void:
    if invincibility > 0.0:
        return
    invincibility = 0.85
    hp = maxi(0, hp - damage)
    _spark(player_pos, Color("#f5bd7e"), 6)
    var away := (player_pos - origin).normalized() * 23.0
    _move_player(away)
    if hp <= 0:
        dead = true
        _say("Try again - the forest needs you.", 3.0)

func _swing() -> void:
    attack_time = 0.22
    attack_cd = 0.40
    _spark(player_pos + facing * 48.0, Color("#ffe5a5"), 5)
    for i in range(enemies.size() - 1, -1, -1):
        var e: Dictionary = enemies[i]
        var delta: Vector2 = e["pos"] - player_pos
        var dist := delta.length()
        var range_limit: float = 93.0 if bool(e["boss"]) else 83.0
        if dist < range_limit and dist > 0.0 and delta.normalized().dot(facing) > 0.15:
            e["hp"] = int(e["hp"]) - power
            e["hit"] = 0.16
            _spark(e["pos"], Color("#ffebaf"), 7)
            if int(e["hp"]) <= 0:
                var was_boss: bool = e["boss"]
                _spark(e["pos"], Color("#e7b96c"), 14)
                enemies.remove_at(i)
                if was_boss:
                    finished = true
                    _say("The Moon Shrine is safe!", 6.0)
                else:
                    kills += 1
                    _gain_xp(28)
    if kills >= MAX_SLIMES and not boss_spawned:
        boss_spawned = true
        enemies.append(_enemy(Vector2(1530, 342), true))
        _say("The FOREST GUARDIAN awakens at the shrine!", 5.0)

func _gain_xp(amount: int) -> void:
    experience += amount
    var threshold := level * 85
    if experience >= threshold:
        experience -= threshold
        level += 1
        max_hp += 15
        hp = mini(max_hp, hp + 30)
        power += 4
        _say("LEVEL UP! Sword power increased.", 2.5)
        _spark(player_pos, Color("#ffe9a8"), 11)

func _spark(p: Vector2, color: Color, count: int) -> void:
    for i in range(count):
        var angle := float(i) * TAU / float(count)
        effects.append({
            "pos": p,
            "vel": Vector2(cos(angle), sin(angle)) * (25.0 + float(i % 4) * 10.0),
            "life": 0.28 + float(i % 3) * 0.07,
            "color": color
        })

func _draw() -> void:
    for p in pickups:
        _draw_potion(p["pos"])
    for e in enemies:
        _draw_enemy(e)
    _draw_player(player_pos)
    if attack_time > 0.0:
        var a := facing.angle()
        var phase := 1.0 - attack_time / 0.22
        draw_arc(player_pos + facing * 12.0, 61.0, a - 1.2 + phase * 0.45, a + 0.75 + phase * 0.45, 11, Color("#3c6b66"), 19.0, false)
        draw_arc(player_pos + facing * 12.0, 57.0, a - 1.1 + phase * 0.45, a + 0.8 + phase * 0.45, 11, Color("#fff1c0"), 10.0, false)
        draw_arc(player_pos + facing * 12.0, 52.0, a - 0.9 + phase * 0.45, a + 0.5 + phase * 0.45, 9, Color("#ffffff"), 4.0, false)
    for e in effects:
        var p: Vector2 = e["pos"]
        var v: Vector2 = e["vel"]
        var life: float = e["life"]
        var size := 3.0 + 6.0 * life
        draw_rect(Rect2(p + v * (0.42 - life), Vector2(size, size)), e["color"])

func _draw_player(p: Vector2) -> void:
    var stride: float = sin(time_passed * 12.0) * 3.5 if (Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) else 0.0
    if invincibility > 0.0 and int(time_passed * 16.0) % 2 == 0:
        return
    # Shadow / boots / forest cloak, all drawn in sharp pixel blocks.
    draw_rect(Rect2(p.x - 21, p.y + 18, 44, 10), Color("#233d36"))
    draw_rect(Rect2(p.x - 16, p.y + 9 + stride, 12, 15), Color("#3f3d42"))
    draw_rect(Rect2(p.x + 5, p.y + 9 - stride, 12, 15), Color("#3f3d42"))
    draw_rect(Rect2(p.x - 20, p.y - 24, 41, 43), Color("#1b3d46"))
    draw_rect(Rect2(p.x - 15, p.y - 20, 31, 31), Color("#44788b"))
    draw_rect(Rect2(p.x - 11, p.y + 3, 23, 8), Color("#ae884e"))
    draw_rect(Rect2(p.x - 23, p.y - 14, 10, 21), Color("#c6a182"))
    draw_rect(Rect2(p.x + 14, p.y - 14, 10, 21), Color("#c6a182"))
    # Hair / face, with four directional differentiation.
    draw_rect(Rect2(p.x - 15, p.y - 43, 31, 26), Color("#513c3c"))
    draw_rect(Rect2(p.x - 11, p.y - 36, 23, 20), Color("#e7b68c"))
    draw_rect(Rect2(p.x - 16, p.y - 47, 32, 13), Color("#55403b"))
    draw_rect(Rect2(p.x - 13, p.y - 49, 25, 5), Color("#92644b"))
    if facing == Vector2.DOWN:
        draw_rect(Rect2(p.x - 7, p.y - 28, 4, 4), Color("#293c43"))
        draw_rect(Rect2(p.x + 6, p.y - 28, 4, 4), Color("#293c43"))
    elif facing == Vector2.UP:
        draw_rect(Rect2(p.x - 11, p.y - 36, 23, 18), Color("#5d4740"))
    elif facing == Vector2.RIGHT:
        draw_rect(Rect2(p.x + 7, p.y - 29, 5, 4), Color("#293c43"))
    else:
        draw_rect(Rect2(p.x - 12, p.y - 29, 5, 4), Color("#293c43"))
    # A sheathed sword on the shoulder.
    var side: float = 1.0 if facing != Vector2.LEFT else -1.0
    draw_line(p + Vector2(side * 23, 8), p + Vector2(side * 25, -28), Color("#d4d3c4"), 6.0, false)
    draw_line(p + Vector2(side * 19, 0), p + Vector2(side * 31, 0), Color("#987345"), 6.0, false)

func _draw_enemy(e: Dictionary) -> void:
    var p: Vector2 = e["pos"]
    var boss: bool = e["boss"]
    var bob := sin(time_passed * 5.0 + float(e["time"])) * 3.0
    var size: float = 38.0 if boss else 23.0
    var flash: bool = float(e["hit"]) > 0.0
    var main: Color = Color("#e8e2bb") if flash else (Color("#a15881") if boss else Color("#82b879"))
    var shade: Color = Color("#553853") if boss else Color("#3b7567")
    draw_rect(Rect2(p.x - size, p.y + 12, size * 2, 12), Color("#284b40"))
    draw_rect(Rect2(p.x - size, p.y - size * 0.8 + bob, size * 2, size * 1.35), shade)
    draw_rect(Rect2(p.x - size + 6, p.y - size + bob, size * 2 - 12, size * 1.32), main)
    draw_rect(Rect2(p.x - size + 9, p.y - size + 4 + bob, size * 0.65, 8), Color("#d4d9a1") if not boss else Color("#d59bac"))
    draw_rect(Rect2(p.x - 11, p.y - 13 + bob, 7, 10), Color("#243737"))
    draw_rect(Rect2(p.x + 7, p.y - 13 + bob, 7, 10), Color("#243737"))
    if boss:
        draw_rect(Rect2(p.x - 31, p.y - 56 + bob, 20, 29), Color("#e5bf74"))
        draw_rect(Rect2(p.x + 12, p.y - 56 + bob, 20, 29), Color("#e5bf74"))
        draw_rect(Rect2(p.x - 20, p.y - 65 + bob, 42, 16), Color("#faf0b0"))
    if int(e["hp"]) < int(e["max"]) or boss:
        draw_rect(Rect2(p.x - size, p.y - size - 21, size * 2, 7), Color("#223730"))
        draw_rect(Rect2(p.x - size + 2, p.y - size - 19, (size * 2 - 4) * float(e["hp"]) / float(e["max"]), 3), Color("#ff9c89"))

func _draw_potion(p: Vector2) -> void:
    var bob := sin(time_passed * 4.0 + p.x) * 4.0
    draw_rect(Rect2(p.x - 12, p.y + 12, 26, 6), Color("#254839"))
    draw_rect(Rect2(p.x - 10, p.y - 10 + bob, 22, 23), Color("#265c62"))
    draw_rect(Rect2(p.x - 6, p.y - 5 + bob, 14, 14), Color("#7edac5"))
    draw_rect(Rect2(p.x - 5, p.y - 17 + bob, 12, 8), Color("#f3cf8f"))
    draw_rect(Rect2(p.x - 2, p.y - 4 + bob, 4, 8), Color("#d5f7db"))
