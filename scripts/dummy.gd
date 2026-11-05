extends StaticBody2D

@export var max_hp: int = 30
var hp: int
@onready var hp_label: Label = $HpLabel

func _ready() -> void:
    hp = max_hp
    _refresh_label()

func take_damage(amount: int) -> void:
    hp = maxi(0, hp - amount)
    _refresh_label()
    if hp <= 0:
        queue_free()

func _refresh_label() -> void:
    hp_label.text = "HP: %d" % hp
