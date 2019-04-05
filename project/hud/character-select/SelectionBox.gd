extends Control

signal selected(character)
signal unselected(character)
signal tried_to_start

enum States {CLOSED, OPEN, READY}

const CHARACTERS = ["Red", "Green", "Purple", "Yellow"]
const DEADZONE = .55

var available_chars = CHARACTERS.duplicate()
var char_index
var device_name = ""
var state = States.CLOSED
var _moved_left = false
var _moved_right = false


func _ready():
	set_process(true)
	randomize()
	var anim_player = $Sprite/AnimationPlayer
	var anim_length = anim_player.current_animation_length
	anim_player.advance(rand_range(0, anim_length))
	$SharkSprite.hide()

func _process(delta):
	if device_name.left(8) == "gamepad_":
		var device_n = int(device_name.right(8))
		var axis_value = Input.get_joy_axis(device_n, 0)
		print(axis_value)
		if axis_value >= DEADZONE and not _moved_right:
			print("right")
			_moved_right = true
			toggle_left()
		elif  axis_value <= -DEADZONE and not _moved_left:
			print("left")
			_moved_left = true
			toggle_right()
		if abs(axis_value) < DEADZONE:
			print("reset")
			_moved_right = false
			_moved_left = false


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
		toggle_left()

	elif event.is_action_pressed("ui_right") and state == States.OPEN:
		toggle_right()

	get_tree().set_input_as_handled()

func toggle_left():
	set_character(char_index - 1)
	$Sprite/State.set_text(CHARACTERS[char_index]) # Can't be in set_charater() or will overwrite initial state
	$Sounds/SelectSFX.play()

func toggle_right():
	set_character(char_index + 1)
	$Sprite/State.set_text(CHARACTERS[char_index]) # Can't be in set_charater() or will overwrite initial state
	$Sounds/SelectSFX.play()

func change_state(new_state):
	match new_state:
		States.CLOSED:
			device_name = ""
			$Sprite/DeviceSprite.set_texture(null)
			$Sprite/DeviceNumber.set_text("")
			$Sprite/State.set_text("PRESS START")
			$SharkSprite.hide()
		States.OPEN:
			$Sprite/State.set_text(CHARACTERS[char_index])
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

	add_shark(CHARACTERS[char_index])

	if not CHARACTERS[char_index] in available_chars:
		pass


func add_shark(shark_name):
	var old = $SharkSprite/Shark
	var new_path = str("res://player/characters/", shark_name, ".tscn")
	var new = load(new_path).instance()

	old.set_name("old shark")
	old.queue_free()
	new.set_name("Shark")
	$SharkSprite.add_child(new)


func _on_AnimationPlayer_animation_finished(anim_name):
	$Sprite/AnimationPlayer.play("idle")
