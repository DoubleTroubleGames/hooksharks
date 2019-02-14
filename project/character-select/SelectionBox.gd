extends Control

signal selected(id)
signal unselected(id)

const characters = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)]
enum States {UNSELECTED, SELECTED, READY}

export(int, 0, 3) var id = 0

var current_state = States.UNSELECTED
var current_character_id = 0


func _input(event):
	if not event is InputEventKey and not event is InputEventJoypadButton:
		return
	var device = determine_device_type(event)
	
	match current_state:
		UNSELECTED:
			if event.is_action_pressed("start"):
				if not device in RoundManager.control_map:
					if(RoundManager.assign_to_port(device)):
						change_state(SELECTED, device)
						emit_signal("selected", id)
		SELECTED:
			if not device == RoundManager.control_map[id]:
				return
			if event.is_action_pressed("ui_cancel"):
				RoundManager.unassign_port(device)
				change_state(UNSELECTED, device)
				emit_signal("unselected", id)
			if event.is_action_pressed("ui_left"):
				current_character_id -= 1
			elif event.is_action_pressed("ui_right"):
				current_character_id += 1
			current_character_id %= characters.size()
			$Sprite.set_modulate(characters[current_character_id])
		READY:
			pass

func determine_device_type(event):
	var device
	if event is InputEventKey:
		device = 'keyboard'
	else:
		device = str("gamepad_", event.device)
	return device
	

func change_state(new_state, device):
	current_state = new_state
	$State.text = str(new_state)
	$DeviceId.text = str(device)
	
	
