extends Node

const ACTION_MAP := {
	"ui_joy_left": "ui_left",
	"ui_joy_right": "ui_right",
	"ui_joy_up": "ui_up",
	"ui_joy_down": "ui_down",
}

export var cooldown_sec := 0.1

var _cooldown := 0.0


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta
		return

	for action in ACTION_MAP:
		if Input.is_action_just_pressed(action):
			send_event(ACTION_MAP[action], true)
			_cooldown = cooldown_sec

		elif Input.is_action_just_released(action):
			send_event(ACTION_MAP[action], false)


func send_event(action: String, pressed: bool) -> void:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		get_tree().input_event(event)
