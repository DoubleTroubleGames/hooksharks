extends Control

onready var boxes = $Boxes.get_children()
onready var bar = $BackIndicator/Progress
onready var anim_player = $BackIndicator/AnimationPlayer

export (bool)var tutorial = false
export (PackedScene)var ModeSelect 
export (PackedScene)var ArenaMode
export (PackedScene)var RaceMode

var available_characters
var starting_game = false
var back_indicator_up_speed = 100
var back_indicator_down_speed = 150
var tutorial_shown = false


func _ready():
	RoundManager.reset_device_map()
  
	available_characters = $Boxes/SelectionBox0.CHARACTERS.duplicate()

	for i in range(boxes.size()):
		boxes[i].connect("selected", self, "_on_box_selected")
		boxes[i].connect("unselected", self, "_on_box_unselected")
		boxes[i].connect("tried_to_start", self, "_on_box_tried_to_start")
		boxes[i].set_character(0)
	
	set_process_input(false)
	Transition.transition_out()
	yield(Transition, "finished")
	set_process_input(true)


func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		bar.value = min(100, bar.value + back_indicator_up_speed*delta)
	else:
		bar.value = max(0, bar.value - back_indicator_down_speed * delta)
	
	if bar.value >= 100:
		transition_to(ModeSelect)
	elif bar.value > 20:
		if anim_player.assigned_animation != "show":
			anim_player.play("show")
	elif bar.value < 1:
		if anim_player.assigned_animation == "show":
			anim_player.play("hide")


func _input(event):
	if event.is_action_pressed("ui_start"):
		for box in boxes:
			if box.is_closed():
				box.open_with(event)
				return


func update_boxes():
	for box in boxes:
		box.update_available_characters(available_characters)


func set_device_map():
	var num_players = 0
	
	for box in boxes:
		if box.is_locked():
			var character = box.CHARACTERS[box.char_index]
			RoundManager.device_map.append(box.device_name)
			RoundManager.character_map.append(character)
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
		transition_to(ArenaMode)
	elif RoundManager.gamemode == "Race":
		transition_to(RaceMode)


func show_start_message():
	var Twn = $StartMessage/Tween
	
	Twn.interpolate_property($StartMessage, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), .5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	Twn.interpolate_property($StartMessage, "position:y", -400, 220, .5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	Twn.start()


func hide_start_message():
	var Twn = $StartMessage/Tween
	
	if ($StartMessage.get_modulate() == Color(1, 1, 1, 1)):
		Twn.interpolate_property($StartMessage, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		Twn.interpolate_property($StartMessage, "position:y", 220, -400, .5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		Twn.start()


func transition_to(packed_scene):
	set_physics_process(false)
	set_process_input(false)
	for box in boxes:
		box.set_process_input(false)
	
	Transition.transition_in()
	yield(Transition, "finished")
	get_tree().change_scene_to(packed_scene)


func _on_box_selected(character):
	var open_boxes = 0
	var ready_boxes = 0
	
	available_characters.erase(character)
	update_boxes()
	
	for box in boxes:
		if box.is_open():
			open_boxes += 1
		elif box.is_ready():
			ready_boxes +=1
	
	if ready_boxes > 0 and open_boxes == 1:
		# For some reason, the box that emits the selected signal is always identified as open, which is
		# why this check is so weird
		show_start_message()


func _on_box_unselected(character):
	available_characters.append(character)
	update_boxes()
	hide_start_message()


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
