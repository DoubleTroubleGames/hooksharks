extends Control


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
