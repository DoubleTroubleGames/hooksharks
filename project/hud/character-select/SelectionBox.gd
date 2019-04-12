extends Control

signal selected(character)
signal unselected(character)
signal tried_to_start

enum States {CLOSED, OPEN, READY}

const CHARACTERS = ["Pirate", "Green", "Drill", "Yellow"]
const DEADZONE = .55

var available_chars = CHARACTERS.duplicate()
var char_index = 0
var device_name = ""
var state = States.CLOSED
var _moved_left = false
var _moved_right = false
var changing = false
var rechange_shark = false


func _ready():
	set_process(true)
	$SharkSprite.hide()

func _process(delta):
	if device_name.left(8) == "gamepad_":
		var device_n = int(device_name.right(8))
		var axis_value = Input.get_joy_axis(device_n, 0)
		if axis_value >= DEADZONE and not _moved_right:
			_moved_right = true
			toggle_left()
		elif  axis_value <= -DEADZONE and not _moved_left:
			_moved_left = true
			toggle_right()
		if abs(axis_value) < DEADZONE:
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
				$Sounds/CancelSFX.play()
		elif state == States.READY:
			$Sounds/CancelSFX.play()
			emit_signal("tried_to_start")

	elif event.is_action_pressed("ui_cancel"):
		if state == States.OPEN:
			device_name = ""
			change_state(States.CLOSED)
			$Sounds/CancelSFX.play()
		elif state == States.READY:
			$Boarder/AnimationPlayer.play("unready")
			change_state(States.OPEN)
			$Sounds/CancelSFX.play()

	elif event.is_action_pressed("ui_left") and state == States.OPEN and not changing:
		toggle_left()

	elif event.is_action_pressed("ui_right") and state == States.OPEN and not changing:
		toggle_right()

	get_tree().set_input_as_handled()


func toggle_left():
	$Boarder/ChangePortrait.set_texture(load(str("res://hud/character-select/", CHARACTERS[char_index], ".png")))
	set_character(char_index - 1)
	#### Visuals for character changing ####
	changing = true
	change_shark()
	$Boarder/Portrait.set_texture(load(str("res://hud/character-select/", CHARACTERS[char_index], ".png")))
	$Boarder/AnimationPlayer.play("change_char_left")
	yield($Boarder/AnimationPlayer, "animation_finished")
	changing = false
	########################################
	$Sounds/SelectSFX.play()


func toggle_right():
	$Boarder/ChangePortrait.set_texture(load(str("res://hud/character-select/", CHARACTERS[char_index], ".png")))
	set_character(char_index + 1)
	#### Visuals for character changing ####
	changing = true
	change_shark()
	$Boarder/Portrait.set_texture(load(str("res://hud/character-select/", CHARACTERS[char_index], ".png")))
	$Boarder/AnimationPlayer.play("change_char_right")
	yield($Boarder/AnimationPlayer, "animation_finished")
	changing = false
	########################################
	$Sounds/SelectSFX.play()


func change_state(new_state):
	match new_state:
		States.CLOSED:
			device_name = ""
			$Boarder/DeviceSprite.set_texture(null)
			$Boarder/DeviceNumber.set_text("")
			$SharkSprite.hide()
			$Boarder/AnimationPlayer.play("close")
		States.OPEN:
			$SharkSprite.show()
			if state == States.READY:
				emit_signal("unselected", CHARACTERS[char_index])
		States.READY:
			emit_signal("selected", CHARACTERS[char_index])
			$Boarder/AnimationPlayer.play("ready")

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
		$Boarder/DeviceSprite.set_texture(load("res://hud/character-select/keyboard.png"))
	else:
		var num = int(device_name.split("_")[1]) + 1
		$Boarder/DeviceSprite.set_texture(load("res://hud/character-select/gamepad.png"))
		$Boarder/DeviceNumber.set_text(str(num))

	$Boarder/AnimationPlayer.play("open")
	$Sounds/ConfirmSFX.play()
	change_state(States.OPEN)


func update_available_characters(characters):
	available_chars = characters
	set_character(char_index)


func set_character(index):
	char_index = wrapi(index, 0, CHARACTERS.size())
	
	if not CHARACTERS[char_index] in available_chars:
		pass


func add_shark(shark_name):
	var old = $SharkSprite/Shark
	var new_path = str("res://player/characters/", shark_name, "/Shark.tscn")
	var new = load(new_path).instance()

	old.set_name("old shark")
	old.queue_free()
	new.set_name("Shark")
	$SharkSprite.add_child(new)


func change_shark():
	var shark_anim = $SharkSprite/Shark/AnimationPlayer
	
	if shark_anim.current_animation != "idle": # shark already changing
		rechange_shark = true
		return
	
	shark_anim.play("dive")
	yield(shark_anim, "animation_finished")
	add_shark(CHARACTERS[char_index])
	shark_anim = $SharkSprite/Shark/AnimationPlayer # since the shark scene was change, we have to update this node
	shark_anim.play("dive_idle")
	yield(get_tree().create_timer(shark_anim.current_animation_length/2), "timeout")
	shark_anim.play("emerge")
	shark_anim.queue("idle")
	
	if rechange_shark:
		yield(get_tree().create_timer(shark_anim.current_animation_length/2), "timeout")
		rechange_shark = false
		shark_anim.play("idle")
		change_shark()
