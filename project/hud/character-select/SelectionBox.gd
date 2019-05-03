extends Control

signal selected(character)
signal unselected(character)
signal tried_to_start

enum States {INACTIVE, CLOSED, OPEN, READY, LOCKED}

const CHARACTERS = ["Pirate", "Green", "Drill", "Yellow"]
const DEADZONE = .55
const TWN_TIME = 0.6

var available_chars = CHARACTERS.duplicate()
var char_index = 0
var device_name = ""
var state = States.CLOSED
var next_state = States.CLOSED # This is kind of redundant, and heavily depends on estabilished logic, but is useful for the grey portraits logic
var _moved_left = false
var _moved_right = false
var mid_animation = false


func _ready():
	set_physics_process(true)
	$SharkSprite.hide()

func _physics_process(delta):
	if device_name.left(8) == "gamepad_":
		var device_n = int(device_name.right(8))
		var axis_value = Input.get_joy_axis(device_n, 0)
		if axis_value >= DEADZONE and state == States.OPEN and  not _moved_right and not mid_animation:
			_moved_right = true
			toggle_left()
		elif  axis_value <= -DEADZONE and state == States.OPEN and not _moved_left and not mid_animation:
			_moved_left = true
			toggle_right()
		elif abs(axis_value) < DEADZONE:
			_moved_right = false
			_moved_left = false


func _input(event):
	if RoundManager.get_device_name_from(event) != device_name:
		return
	
	if event.is_action_pressed("ui_select") and not mid_animation:
		if state == States.OPEN:
			if CHARACTERS[char_index] in available_chars:
				change_state(States.READY)
				$Sounds/ConfirmSFX.play()
			else:
				$Sounds/CancelSFX.play()
		elif state == States.READY or state == States.LOCKED:
			emit_signal("tried_to_start")

	elif event.is_action_pressed("ui_cancel") and not mid_animation:
		if state == States.OPEN:
			device_name = ""
			change_state(States.CLOSED)
			$Sounds/CancelSFX.play()
		elif state == States.READY:
			mid_animation = true
			$Boarder/AnimationPlayer.play("unready")
			change_state(States.OPEN)
			$Sounds/CancelSFX.play()
			yield($Boarder/AnimationPlayer, "animation_finished")
			mid_animation = false
			

	elif event.is_action_pressed("ui_left") and state == States.OPEN and not mid_animation:
		toggle_left()

	elif event.is_action_pressed("ui_right") and state == States.OPEN and not mid_animation:
		toggle_right()

	get_tree().set_input_as_handled()


func toggle_left():
	var portrait_path = str("res://characters/", CHARACTERS[char_index], "/portrait")
	if not CHARACTERS[char_index] in available_chars:
		portrait_path += "_grey"
	portrait_path += ".png"
	$Boarder/ChangePortrait.set_texture(load(portrait_path))
	set_character(char_index - 1)
	change_shark()
	$Sounds/SelectSFX.play()
	#### Visuals for character changing ####
	mid_animation = true
	portrait_path = str("res://characters/", CHARACTERS[char_index], "/portrait")
	if not CHARACTERS[char_index] in available_chars:
		portrait_path += "_grey"
	portrait_path += ".png"
	$Boarder/Portrait.set_texture(load(portrait_path))
	$Boarder/AnimationPlayer.play("change_char_left")
	yield($Boarder/AnimationPlayer, "animation_finished")
	mid_animation = false
	########################################


func toggle_right():
	var portrait_path = str("res://characters/", CHARACTERS[char_index], "/portrait")
	if not CHARACTERS[char_index] in available_chars:
		portrait_path += "_grey"
	portrait_path += ".png"
	$Boarder/ChangePortrait.set_texture(load(portrait_path))
	set_character(char_index + 1)
	change_shark()
	$Sounds/SelectSFX.play()
	#### Visuals for character changing ####
	mid_animation = true
	portrait_path = str("res://characters/", CHARACTERS[char_index], "/portrait")
	if not CHARACTERS[char_index] in available_chars:
		portrait_path += "_grey"
	portrait_path += ".png"
	$Boarder/Portrait.set_texture(load(portrait_path))
	$Boarder/AnimationPlayer.play("change_char_right")
	yield($Boarder/AnimationPlayer, "animation_finished")
	mid_animation = false
	########################################


func change_state(new_state):
	next_state = new_state
	match new_state:
		States.CLOSED:
			device_name = ""
			$Boarder/DeviceSprite.set_texture(null)
			$Boarder/DeviceNumber.set_text("")
			$Boarder/Left.hide()
			$Boarder/Right.hide()
			$SharkSprite.hide()
			$Boarder/AnimationPlayer.play("close")
			mid_animation = true
			yield($Boarder/AnimationPlayer, "animation_finished")
			mid_animation = false
		States.OPEN:
			if device_name.split("_")[0] == "gamepad":
				$Boarder/DeviceNumber.set_text(device_name.split("_")[1])
			$SharkSprite.show()
			$Boarder/Left.show()
			$Boarder/Right.show()
			if state == States.READY:
				emit_signal("unselected", CHARACTERS[char_index])
		States.READY:
			emit_signal("selected", CHARACTERS[char_index])
			mid_animation = true
			$Boarder/AnimationPlayer.play("ready")
			yield($Boarder/AnimationPlayer, "animation_finished")
			mid_animation = false

	state = next_state

func is_inactive():
	return state == States.INACTIVE

func is_closed():
	return state == States.CLOSED

func is_open():
	return state == States.OPEN

func is_ready():
	return state == States.READY

func is_locked():
	return state == States.LOCKED


func open_with(event):
	device_name = RoundManager.get_device_name_from(event)
	if device_name == "keyboard" or (OS.is_debug_build() and device_name == "test_keyboard"):
		$Boarder/DeviceSprite.set_texture(load("res://hud/character-select/keyboard.png"))
	else:
		var num = int(device_name.split("_")[1]) + 1
		$Boarder/DeviceSprite.set_texture(load("res://hud/character-select/gamepad.png"))
		$Boarder/DeviceNumber.set_text(str(num))

	if not CHARACTERS[char_index] in available_chars:
		$Boarder/Portrait.set_texture(load(str("res://characters/", CHARACTERS[char_index], "/portrait_grey.png")))
	$Boarder/AnimationPlayer.play("open")
	mid_animation = true
	$Sounds/ConfirmSFX.play()
	change_state(States.OPEN)
	yield($Boarder/AnimationPlayer, "animation_finished")
	mid_animation = false


func update_available_characters(characters):
	available_chars = characters
	set_character(char_index)


func set_character(index):
	char_index = wrapi(index, 0, CHARACTERS.size())
	
	if not CHARACTERS[char_index] in available_chars and self.next_state != States.READY:
		$Boarder/Portrait.set_texture(load(str("res://characters/", CHARACTERS[char_index], "/portrait_grey.png")))
	else:
		$Boarder/Portrait.set_texture(load(str("res://characters/", CHARACTERS[char_index], "/portrait.png")))
	


func add_shark(shark_name):
	var old = $SharkSprite/Shark
	var new_path = str("res://characters/", shark_name, "/Shark.tscn")
	var new = load(new_path).instance()

	old.set_name("old shark")
	old.queue_free()
	new.set_name("Shark")
	new.set_modulate(Color(1, 1, 1, 0))
	new.get_node("Rider").hide()
	$SharkSprite.add_child(new)
	emerge_shark()


func change_shark():
	var SharkTimer = $SharkSprite/SharkChangeTimer
	
	if SharkTimer.time_left == 0: # not dived
		dive_shark()
	SharkTimer.start()


func emerge_shark():
	var Twn = $SharkSprite/SharkChangeTween
	var SharkAnim = $SharkSprite/Shark/AnimationPlayer
	var Shark = $SharkSprite/Shark
	
	Twn.interpolate_property(Shark, "modulate", null, Color(1, 1, 1, 1), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	Twn.start()
	SharkAnim.play("emerge")
	SharkAnim.queue("idle")


func dive_shark():
	var Twn = $SharkSprite/SharkChangeTween
	var SharkAnim = $SharkSprite/Shark/AnimationPlayer
	var Shark = $SharkSprite/Shark
	
	Twn.interpolate_property(Shark, "modulate", null, Color(1, 1, 1, 0), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	Twn.start()
	SharkAnim.play("dive")


func _on_SharkChangeTimer_timeout():
	add_shark(CHARACTERS[char_index])
