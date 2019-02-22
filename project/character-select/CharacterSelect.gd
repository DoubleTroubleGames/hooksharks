extends Control

onready var boxes = $Boxes.get_children()

var available_characters

func _ready():
	available_characters = $Boxes/SelectionBox0.CHARACTERS.duplicate()

	for i in range(boxes.size()):
		pass
		boxes[i].connect("selected", self, "_on_box_selected")
		boxes[i].connect("unselected", self, "_on_box_unselected")
		boxes[i].connect("readied", self, "_on_box_readied")
		boxes[i].set_character(0)


func _input(event):
	if event.is_action_pressed("ui_start"):
		for box in boxes:
			if box.is_closed():
				box.open_with(event)
				return
	elif event.is_action_pressed("ui_cancel"):
		# Go to previous screen
		pass


func update_boxes():
	for box in boxes:
		box.update_available_characters(available_characters)


func _on_box_selected(character):
	available_characters.erase(character)
	update_boxes()


func _on_box_unselected(character):
	available_characters.append(character)
	update_boxes()


func _on_box_readied():
	var ready_boxes = 0
	
	for box in boxes:
		if box.is_open():
			return
		elif box.is_ready():
			ready_boxes += 1
	if ready_boxes < 2:
		return

	if RoundManager.gamemode == "Arena":
		get_tree().change_scene("res://arena-mode/Arena.tscn")
	elif RoundManager.gamemode == "Race":
		get_tree().change_scene("res://race-mode/Race.tscn")
