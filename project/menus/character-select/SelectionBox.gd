extends Control

signal selected(character)
signal unselected(character)
signal closed()
signal tried_to_start

enum MovementTypes {DIRECT, TANK}
enum States {INACTIVE, CLOSED, OPEN, READY, LOCKED}

const CHARACTERS = ["jackie", "drill", "king", "outsider"]
const PORTRAITS = [
		preload("res://assets/images/characters/jackie/portrait.png"),
		preload("res://assets/images/characters/drill/portrait.png"),
		preload("res://assets/images/characters/king/portrait.png"),
		preload("res://assets/images/characters/outsider/portrait.png"),
]
const DEADZONE = .55
const DIRECT = preload("res://assets/images/ui/direct.png")
const GAMEPAD = preload("res://assets/images/ui/gamepad.png")
const KEYBOARD = preload("res://assets/images/ui/keyboard.png")
const TANK = preload("res://assets/images/ui/tank.png")
const TWN_TIME = 0.6
const SHARKS = {
	"drill": preload("res://characters/drill/Shark.tscn"),
	"jackie": preload("res://characters/jackie/Shark.tscn"),
	"king": preload("res://characters/king/Shark.tscn"),
	"outsider": preload("res://characters/outsider/Shark.tscn"),
}

onready var char_sfx = {"jackie": $Sounds/JackieSFXs,
		"drill": $Sounds/DrillSFXs, "king": $Sounds/KingSFXs,
		"outsider": $Sounds/OutsiderSFXs}

var available_chars = CHARACTERS.duplicate()
var char_index = 0
var device_name = ""
var movement_type = MovementTypes.DIRECT
var state = States.CLOSED
var next_state = States.CLOSED # This is kind of redundant, and heavily depends on estabilished logic, but is useful for the grey portraits logic
var _moved_left = false
var _moved_right = false
var _moved_up = false
var _moved_down = false
var mid_animation = false


func _ready():
	set_physics_process(true)
	$SharkSprite.hide()

func _physics_process(delta):
	# This handles gamepad input
	if device_name.left(8) != "gamepad_":
		return

	if mid_animation:
		return

	if state != States.OPEN:
		return

	var device_n = int(device_name.right(8))
	var axis_value_x = Input.get_joy_axis(device_n, 0)
	var axis_value_y = Input.get_joy_axis(device_n, 1)

	if abs(axis_value_x) < DEADZONE:
		_moved_left = false
		_moved_right = false

	if abs(axis_value_y) < DEADZONE:
		_moved_up = false
		_moved_down = false

	if  axis_value_x <= -DEADZONE and not _moved_left:
		_moved_left = true
		toggle_left()

	elif axis_value_x >= DEADZONE and not _moved_right:
		_moved_right = true
		toggle_right()

	elif  axis_value_y <= -DEADZONE and not _moved_up:
		_moved_up = true
		toggle_up()

	elif axis_value_y >= DEADZONE and not _moved_down:
		_moved_down = true
		toggle_down()


func _input(event):
	# This handles keyboard input
	if RoundManager.get_device_name_from(event) != device_name:
		return

	# Don't mark input as handled so FullscreenToggle can get this input.
	if event.is_action_pressed("toggle_fullscreen"):
		return

	if mid_animation:
		get_tree().set_input_as_handled()
		return

	if event.is_action_pressed("ui_select"):
		if state == States.OPEN:
			if CHARACTERS[char_index] in available_chars:
				change_state(States.READY)
				$Sounds/ConfirmSFX.play()
				var sfxs = char_sfx[CHARACTERS[char_index]]
				var sfx_number = randi() % sfxs.get_child_count()
				sfxs.get_child(sfx_number).play()

			else:
				$Sounds/CancelSFX.play()

		elif state == States.READY or state == States.LOCKED:
			emit_signal("tried_to_start")

	elif event.is_action_pressed("ui_cancel"):
		if state == States.OPEN:
			device_name = ""
			change_state(States.CLOSED)
			$Sounds/CancelSFX.play()

		elif state == States.READY:
			mid_animation = true
			$Border/AnimationPlayer.play("unready")
			change_state(States.OPEN)
			$Sounds/CancelSFX.play()
			yield($Border/AnimationPlayer, "animation_finished")
			mid_animation = false

	# This makes it so each subsequent elif doesn't need to check if state == States.OPEN
	elif state != States.OPEN:
		get_tree().set_input_as_handled()
		return

	elif event.is_action_pressed("ui_left"):
		toggle_left()

	elif event.is_action_pressed("ui_right"):
		toggle_right()

	elif event.is_action_pressed("ui_up"):
		toggle_up()

	elif event.is_action_pressed("ui_down"):
		toggle_down()

	get_tree().set_input_as_handled()


func toggle_left():
	var grey_factor = 0
	if not CHARACTERS[char_index] in available_chars:
		grey_factor = 1

	$Border/ChangePortrait.set_texture(PORTRAITS[char_index])
	$Border/ChangePortrait.material.set_shader_param("grey_factor", grey_factor)
	set_character(char_index - 1)
	change_shark()
	$Sounds/SelectSFX.play()
	#### Visuals for character changing ####
	mid_animation = true
	grey_factor = 0
	if not CHARACTERS[char_index] in available_chars:
		grey_factor = 1

	$Border/Portrait.set_texture(PORTRAITS[char_index])
	$Border/Portrait.material.set_shader_param("grey_factor", grey_factor)
	$Border/AnimationPlayer.play("change_char_right")
	yield($Border/AnimationPlayer, "animation_finished")
	mid_animation = false
	########################################


func toggle_right():
	var grey_factor = 0
	if not CHARACTERS[char_index] in available_chars:
		grey_factor = 1

	$Border/ChangePortrait.set_texture(PORTRAITS[char_index])
	$Border/ChangePortrait.material.set_shader_param("grey_factor", grey_factor)
	set_character(char_index + 1)
	change_shark()
	$Sounds/SelectSFX.play()
	#### Visuals for character changing ####
	mid_animation = true
	grey_factor = 0
	if not CHARACTERS[char_index] in available_chars:
		grey_factor = 1

	$Border/Portrait.set_texture(PORTRAITS[char_index])
	$Border/Portrait.material.set_shader_param("grey_factor", grey_factor)
	$Border/AnimationPlayer.play("change_char_left")
	yield($Border/AnimationPlayer, "animation_finished")
	mid_animation = false
	########################################


func toggle_up():
	toggle_movement_type()
	$Sounds/SelectSFX.play()


func toggle_down():
	toggle_movement_type()
	$Sounds/SelectSFX.play()


func change_state(new_state):
	next_state = new_state
	match new_state:
		States.CLOSED:
			dive_shark()
			device_name = ""
			$Border/DeviceSprite.set_texture(null)
			$Border/MoveTypeSprite.set_texture(null)
			$Border/Left.hide()
			$Border/Right.hide()
			$Border/Up.hide()
			$Border/Down.hide()
			$SharkSprite.hide()
			$Border/AnimationPlayer.play("close")
			mid_animation = true
			yield($Border/AnimationPlayer, "animation_finished")
			mid_animation = false
			emit_signal("closed")
		States.OPEN:
			$SharkSprite.show()
			if state == States.CLOSED:
				emerge_shark()
			$Border/Left.show()
			$Border/Right.show()
			$Border/Up.show()
			$Border/Down.show()
			if state == States.READY:
				emit_signal("unselected", CHARACTERS[char_index])
		States.READY:
			emit_signal("selected", CHARACTERS[char_index])
			mid_animation = true
			$Border/AnimationPlayer.play("ready")
			yield($Border/AnimationPlayer, "animation_finished")
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
		$Border/DeviceSprite.set_texture(KEYBOARD)
		set_movement_type(MovementTypes.TANK)

	else:
		var num = int(device_name.split("_")[1]) + 1
		$Border/DeviceSprite.set_texture(GAMEPAD)
		set_movement_type(MovementTypes.DIRECT)

	if not CHARACTERS[char_index] in available_chars:
		$Border/Portrait.material.set_shader_param("grey_factor", 1)

	$Border/AnimationPlayer.play("open")
	mid_animation = true
	$Sounds/ConfirmSFX.play()
	change_state(States.OPEN)
	yield($Border/AnimationPlayer, "animation_finished")
	mid_animation = false


func update_available_characters(characters):
	available_chars = characters
	set_character(char_index)


func set_character(index):
	char_index = wrapi(index, 0, CHARACTERS.size())
	
	var grey_factor = 0
	if not CHARACTERS[char_index] in available_chars and self.next_state != States.READY:
		grey_factor = 1

	$Border/Portrait.set_texture(PORTRAITS[char_index])
	$Border/Portrait.material.set_shader_param("grey_factor", grey_factor)


func set_movement_type(new_movement_type):
	match new_movement_type:
		MovementTypes.DIRECT:
			movement_type = MovementTypes.DIRECT
			$Border/MoveTypeSprite.set_texture(DIRECT)

		MovementTypes.TANK:
			movement_type = MovementTypes.TANK
			$Border/MoveTypeSprite.set_texture(TANK)


func toggle_movement_type():
	if movement_type == MovementTypes.DIRECT:
		set_movement_type(MovementTypes.TANK)

	else:
		set_movement_type(MovementTypes.DIRECT)


func add_shark(shark_name):
	var old = $SharkSprite/Shark
	var new = SHARKS[shark_name].instance()

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
