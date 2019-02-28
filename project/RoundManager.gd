extends Node

const DEBUG_KEYS = [KEY_PERIOD, KEY_SEMICOLON, KEY_J, KEY_K, KEY_L, KEY_I]

var scores = [0, 0]
var round_number = 1
var winner = -1
var gamemode # 'Arena' or 'Race'
var device_map = []


func get_device_name_from(event):
	if event is InputEventKey:
		if event.scancode in DEBUG_KEYS:
			if OS.is_debug_build():
				return "test_keyboard"
			else:
				return "invalid_device"
		
		return "keyboard"
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return str("gamepad_", event.device)
	
	return "invalid_device"
