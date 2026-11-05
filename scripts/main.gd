extends Node2D

# Add input actions before TouchScreenButton children join the tree.
func _enter_tree() -> void:
    _add_keys("move_up", [KEY_W, KEY_UP])
    _add_keys("move_down", [KEY_S, KEY_DOWN])
    _add_keys("move_left", [KEY_A, KEY_LEFT])
    _add_keys("move_right", [KEY_D, KEY_RIGHT])
    _add_keys("attack", [KEY_J, KEY_SPACE])

func _add_keys(action: StringName, keycodes: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    for keycode in keycodes:
        var event := InputEventKey.new()
        event.physical_keycode = keycode
        InputMap.action_add_event(action, event)
