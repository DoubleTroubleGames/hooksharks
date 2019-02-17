extends Control

var ready_num = 0

func _ready():
	get_node("GridContainer/SelectionBox0").set_process_input(true)


func _on_SelectionBox_selected(id):
	var next_id = RoundManager.get_open_port()
	get_node(str("GridContainer/SelectionBox", next_id)).set_process_input(true)


# Turns off all empty boxes, then turns on the first empty box it finds
func _on_SelectionBox_unselected(id):
	var i = 0
	for port in RoundManager.control_map:
		if port == null:
			get_node(str("GridContainer/SelectionBox", i)).set_process_input(false)
		i += 1
	var next_id = RoundManager.get_open_port()
	get_node(str("GridContainer/SelectionBox", next_id)).set_process_input(true)


func _on_SelectionBox_ready(id):
	ready_num += 1


func _on_SelectionBox_unready(id):
	ready_num -= 1


func _on_SelectionBox_start_game():
	if ready_num > 1:
		if RoundManager.gamemode == "Arena":
			get_tree().change_scene("res://arena-mode/Arena.tscn")
		elif RoundManager.gamemode == "Race":
			get_tree().change_scene("res://race-mode/SplitScreen2.tscn")
