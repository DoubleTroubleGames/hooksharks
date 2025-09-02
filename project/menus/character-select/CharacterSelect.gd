extends Control

export(bool) var tutorial = false

var available_characters
var starting_game = false
var tutorial_shown = false

onready var boxes = $Boxes.get_children()


func _ready():
	RoundManager.reset_device_map()

	available_characters = $Boxes/SelectionBox0.CHARACTERS.duplicate()

	for i in range(boxes.size()):
		boxes[i].connect("selected", self, "_on_box_selected")
		boxes[i].connect("unselected", self, "_on_box_unselected")
		boxes[i].connect("tried_to_start", self, "_on_box_tried_to_start")
		boxes[i].connect("closed", self, "_on_box_closed")
		boxes[i].set_character(0)

	set_process_input(false)


func _on_transition_in() -> void:
	set_physics_process(false)


func _on_transition_out() -> void:
	set_process_input(true)

	if RoundManager.gamemode == "Arena":
		$Sounds/ArenaSFX.play()
	elif RoundManager.gamemode == "Race":
		$Sounds/RaceSFX.play()


func _input(event):
	if event.is_action_pressed("ui_start"):
		for box in boxes:
			if box.is_closed():
				box.open_with(event)
				hide_start_message()
				return


func update_boxes():
	for box in boxes:
		box.update_available_characters(available_characters)
	if not can_start():
		hide_start_message()


func set_device_map():
	var num_players = 0

	for box in boxes:
		if box.is_locked():
			var character = box.CHARACTERS[box.char_index]
			RoundManager.device_map.append(box.device_name)
			RoundManager.character_map.append(character)
			RoundManager.movement_type_map.append(box.movement_type)
			num_players += 1

	RoundManager.players_total = num_players


func can_start():
	var ready_players = 0

	for box in boxes:
		if box.is_open():
			return false
		if box.is_ready() or box.is_locked():
			ready_players += 1

	if ready_players > 1:
		return true
	return false


func start_game():
	if starting_game:
		return

	starting_game = true
	Sound.fade_out(Sound.menu_bgm)

	set_device_map()
	RoundManager.reset_round()

	if RoundManager.gamemode == "Arena":
		Transition.transition_to("ArenaMode")
	elif RoundManager.gamemode == "Race":
		Transition.transition_to("RaceMode")


func show_start_message():
	var twn = $StartMessage/Tween

	twn.interpolate_property(
		$StartMessage,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		.5,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	twn.interpolate_property(
		$StartMessage, "position:y", -400, 220, .5, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	twn.start()


func hide_start_message():
	var twn = $StartMessage/Tween

	if $StartMessage.get_modulate() == Color(1, 1, 1, 1):
		twn.interpolate_property(
			$StartMessage,
			"modulate",
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			.5,
			Tween.TRANS_QUAD,
			Tween.EASE_IN_OUT
		)
		twn.interpolate_property(
			$StartMessage, "position:y", 220, -400, .5, Tween.TRANS_CUBIC, Tween.EASE_IN
		)
		twn.start()


func _on_BackIndicator_completed() -> void:
	Transition.transition_to("ModeSelect")


func _on_box_selected(character):
	var open_boxes = 0
	var ready_boxes = 0

	available_characters.erase(character)
	update_boxes()

	for box in boxes:
		if box.is_open():
			open_boxes += 1
		elif box.is_ready():
			ready_boxes += 1

	if ready_boxes > 0 and open_boxes == 1:
		# For some reason, the box that emits the selected signal is always identified as open, which is
		# why this check is so weird
		show_start_message()


func _on_box_unselected(character):
	available_characters.append(character)
	update_boxes()

	hide_start_message()


func _on_box_closed():
	var open_boxes = 0
	var ready_boxes = 0

	for box in boxes:
		if box.is_open():
			open_boxes += 1
		elif box.is_ready():
			ready_boxes += 1

	print(ready_boxes, open_boxes)
	if ready_boxes > 0 and open_boxes == 1:
		# For some reason, the box that emits the selected signal is always identified as open, which is
		# why this check is so weird
		show_start_message()


func _on_box_tried_to_start():
	if can_start():
		$Sounds/PressStartSFX.play()
		if tutorial:
			if tutorial_shown:
				start_game()
			else:
				for box in boxes:
					if box.is_ready() or box.is_locked():
						box.change_state(box.States.LOCKED)
					else:
						box.change_state(box.States.INACTIVE)
				$TutorialNode/Tutorial/AnimationPlayer.play("show")
				yield($TutorialNode/Tutorial/AnimationPlayer, "animation_finished")
				$TutorialNode/Tutorial/Continue/AnimationPlayer.play("show")
				tutorial_shown = true
		else:
			start_game()
	else:
		$Sounds/DenySFX.play()
