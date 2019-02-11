extends Control

enum States {UNSELECTED, SELECTED, READY}

var current_state = States.UNSELECTED


func _input(event):
	match current_state:
		UNSELECTED:
			if event.is_action_pressed("start"):
				if event is InputEventKey:
					RoundManager.control_map.append('keyboard')
				else:
					RoundManager.control_map.append(event.device)
				change_state(SELECTED, event.device)
				print(RoundManager.control_map)
		SELECTED:
			pass
		READY:
			pass

func change_state(new_state, device_id):
	current_state = new_state
	$State.text = str(new_state)
	$DeviceId.text = str(device_id)
	
	
