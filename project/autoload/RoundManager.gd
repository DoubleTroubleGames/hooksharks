extends Node

const DEBUG_KEYS = [KEY_PERIOD, KEY_SEMICOLON, KEY_J, KEY_K, KEY_L, KEY_I, KEY_SLASH]
const MATCH_POINTS = 5
const CHAR_COLOR = {"jackie" : Color(.7, 0, .4), "drill" : Color(.4, .4, .7),
		"king" : Color(.9, .9, .25), "outsider" : Color(0, .8, 0)}

var scores
var round_number
var round_winner
var gamemode # 'Arena' or 'Race'
var device_map = []
var character_map = []
var players_total = 0


func get_device_name_from(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if OS.is_debug_build() and\
				((event is InputEventKey and event.scancode in DEBUG_KEYS) or\
				(event is InputEventMouseButton and event.button_index == BUTTON_RIGHT)):
			return "test_keyboard"
		
		return "keyboard"
	
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return str("gamepad_", event.device)
	
	return "invalid_device"


func get_match_winner():
	for i in range(players_total):
		if scores[i] >= MATCH_POINTS:
			return i
	
	return -1


func reset_device_map():
	device_map.clear()
	character_map.clear()
	players_total = 0


func reset_round():
	round_number = 1
	round_winner = -1
	scores = []
	for i in range(players_total):
		scores.append(0)
