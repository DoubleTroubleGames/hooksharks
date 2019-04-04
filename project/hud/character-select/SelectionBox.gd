extends Control

signal selected(character)
signal unselected(character)
signal tried_to_start

enum States {CLOSED, OPEN, READY}

const CHARACTERS = [Color(1, 1, 1), Color(1, .4, .4), Color(.4, .4, 1), Color(.4, 1, .4)]

var available_chars = CHARACTERS.duplicate()
var char_index
var device_name = ""
var state = States.CLOSED


func _ready():
	randomize()
	var anim_player = $Sprite/AnimationPlayer
	var anim_length = anim_player.current_animation_length
	anim_player.advance(rand_range(0, anim_length))


func _input(event):
	if RoundManager.get_device_name_from(event) != device_name:
		return
	
	if event.is_action_pressed("ui_start"):
		if state == States.OPEN:
			if CHARACTERS[char_index] in available_chars:
				change_state(States.READY)
				$Sounds/ConfirmSFX.play()
			else:
				$Sprite/AnimationPlayer.play("shake")
				$Sounds/CancelSFX.play()
		elif state == States.READY:
			$Sprite/AnimationPlayer.play("shake")
			$Sounds/CancelSFX.play()
			emit_signal("tried_to_start")
	
	elif event.is_action_pressed("ui_cancel"):
		if state == States.OPEN:
			device_name = ""
			change_state(States.CLOSED)
			$Sounds/CancelSFX.play()
		elif state == States.READY:
			change_state(States.OPEN)
			$Sounds/CancelSFX.play()
	
	elif event.is_action_pressed("ui_left") and state == States.OPEN:
		set_character(char_index - 1)
		$Sprite/State.set_text(str("Char ", char_index + 1)) # Can't be in set_charater() or will overwrite initial state
		$Sounds/SelectSFX.play()
	
	elif event.is_action_pressed("ui_right") and state == States.OPEN:
		set_character(char_index + 1)
		$Sprite/State.set_text(str("Char ", char_index + 1)) # Can't be in set_charater() or will overwrite initial state
		$Sounds/SelectSFX.play()
	
	get_tree().set_input_as_handled()


func change_state(new_state):
	match new_state:
		States.CLOSED:
			device_name = ""
			$Sprite/DeviceSprite.set_texture(null)
			$Sprite/DeviceNumber.set_text("")
			$Sprite/State.set_text("PRESS START")
			$SharkSprite.hide()
		States.OPEN:
			$Sprite/State.set_text(str("Char ", char_index + 1))
			$SharkSprite.show()
			if state == States.READY:
				emit_signal("unselected", CHARACTERS[char_index])
		States.READY:
			$Sprite/State.set_text("READY")
			emit_signal("selected", CHARACTERS[char_index])
	
	state = new_state


func is_closed():
	return state == States.CLOSED


func is_open():
	return state == States.OPEN


func is_ready():
	return state == States.READY


func open_with(event):
	device_name = RoundManager.get_device_name_from(event)
	if device_name == "keyboard" or (OS.is_debug_build() and device_name == "test_keyboard"):
		$Sprite/DeviceSprite.set_texture(load("res://hud/character-select/keyboard.png"))
	else:
		$Sprite/DeviceSprite.set_texture(load("res://hud/character-select/gamepad.png"))
		var num = int(device_name.split("_")[1]) + 1
		$Sprite/DeviceNumber.set_text(str(num))
		
	$Sounds/ConfirmSFX.play()	
	change_state(States.OPEN)


func update_available_characters(characters):
	available_chars = characters
	set_character(char_index)


func set_character(index):
	char_index = wrapi(index, 0, CHARACTERS.size()) 
	$SharkSprite.set_modulate(CHARACTERS[char_index])
	
	if not CHARACTERS[char_index] in available_chars:
		pass


func _on_AnimationPlayer_animation_finished(anim_name):
	$Sprite/AnimationPlayer.play("idle")
