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
	for box in boxes:
		if not box.is_closed() and not box.is_ready():
			return

	# Go to next screen
