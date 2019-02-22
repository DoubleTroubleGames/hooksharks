extends Node

var scores = [0, 0]
var round_number = 1
var winner = -1
var gamemode # 'Arena' or 'Race'
var control_map = [null, null, null, null]

func get_open_port():
	return control_map.find(null)

func assign_to_port(device):
	if get_open_port() != -1:
		control_map[get_open_port()] = device
		return true
	else:
		return false

func unassign_port(device):
	control_map[control_map.find(device)] = null