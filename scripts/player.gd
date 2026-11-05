extends CharacterBody2D

@export var move_speed: float = 150.0
@export var attack_damage: int = 10
@export var attack_duration: float = 0.18
@export var attack_cooldown: float = 0.35

const HERO_UP = preload("res://assets/hero_up.png")
const HERO_DOWN = preload("res://assets/hero_down.png")
const HERO_LEFT = preload("res://assets/hero_left.png")
const HERO_RIGHT = preload("res://assets/hero_right.png")

@onready var hero: Sprite2D = $Hero
@onready var attack_area: Area2D = $AttackArea
@onready var slash: Sprite2D = $AttackArea/Slash

var facing: Vector2 = Vector2.DOWN
var attacking: bool = false
var on_cooldown: bool = false

func _ready() -> void:
    attack_area.monitoring = false
    slash.visible = false
    _update_sprite()

func _physics_process(_delta: float) -> void:
    # Exactly four directions. Horizontal input has priority over vertical input.
    var direction := Vector2.ZERO
    if Input.is_action_pressed("move_left"):
        direction = Vector2.LEFT
    elif Input.is_action_pressed("move_right"):
        direction = Vector2.RIGHT
    elif Input.is_action_pressed("move_up"):
        direction = Vector2.UP
    elif Input.is_action_pressed("move_down"):
        direction = Vector2.DOWN

    if direction != Vector2.ZERO and not attacking:
        facing = direction
        _update_sprite()

    velocity = direction * move_speed
    move_and_slide()

    if Input.is_action_just_pressed("attack") and not on_cooldown:
        _attack()

func _update_sprite() -> void:
    if facing == Vector2.UP:
        hero.texture = HERO_UP
    elif facing == Vector2.DOWN:
        hero.texture = HERO_DOWN
    elif facing == Vector2.LEFT:
        hero.texture = HERO_LEFT
    else:
        hero.texture = HERO_RIGHT

func _attack() -> void:
    attacking = true
    on_cooldown = true
    attack_area.position = facing * 36.0
    slash.rotation = facing.angle()
    slash.visible = true
    attack_area.set_deferred("monitoring", true)

    await get_tree().create_timer(attack_duration).timeout
    if not is_inside_tree():
        return
    slash.visible = false
    attack_area.set_deferred("monitoring", false)
    attacking = false

    await get_tree().create_timer(maxf(0.0, attack_cooldown - attack_duration)).timeout
    if not is_inside_tree():
        return
    on_cooldown = false

func _on_attack_area_body_entered(body: Node2D) -> void:
    if attacking and body.has_method("take_damage"):
        body.take_damage(attack_damage)
