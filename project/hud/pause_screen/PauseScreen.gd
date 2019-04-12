extends CanvasLayer

onready var background = $Background
onready var buttons = [$Background/CenterContainer/VBoxContainer/Resume,
		$Background/CenterContainer/VBoxContainer/Quit]
onready var player_label = $Background/CenterContainer/VBoxContainer/HBoxContainer/Player

enum {RESUME, QUIT}

const UNSELECTED_COLOR = Color(1, 1, 1)
const SELECTED_COLOR = Color(1, 1, .5)
const DEADZONE = .55

var btn_index = 0
var player_device = "keyboard"
onready var _moved_up = false
onready var _moved_down = false

func _ready():
	buttons[btn_index].modulate = SELECTED_COLOR
	set_process_input(false)
	set_process(true)

func _process(delta):
	if player_device.left(8) == "gamepad_":
			var device_n = int(player_device.right(8))
			var axis_value = Input.get_joy_axis(device_n, 1)
			if axis_value >= DEADZONE and not _moved_down:
				_moved_down = true
				change_button(+1)
			elif  axis_value <= -DEADZONE and not _moved_up:
				_moved_up = true
				change_button(-1)
			if abs(axis_value) < DEADZONE:
				_moved_down = false
				_moved_up = false

func _input(event):
	if RoundManager.get_device_name_from(event) != player_device:
		return
	
	if event.is_action_pressed("ui_up"):
		change_button(-1)
	elif event.is_action_pressed("ui_down"):
		change_button(+1)
	elif event.is_action_pressed("ui_accept"):
		press_button()
	elif event.is_action_pressed("ui_cancel"):
		unpause()


func change_button(direction):
	buttons[btn_index].modulate = UNSELECTED_COLOR
	btn_index = wrapi(btn_index + direction, 0, buttons.size())
	buttons[btn_index].modulate = SELECTED_COLOR


func press_button():
	match btn_index:
		RESUME:
			unpause()
		QUIT:
			quit()


func pause(player):
	var color = RoundManager.CHAR_COLOR[RoundManager.character_map[player.id]]
	get_tree().paused = true
	background.visible = true
	set_process_input(true)
	player_device.set_modulate(color)
	player_label.set_modulate(color)
	player_device = player.device_name
	player_label.text = str("P", player.id + 1)


func unpause():
	get_tree().paused = false
	background.visible = false
	set_process_input(false)


func quit():
	set_process_input(false)
	Transition.transition_in()
	yield(Transition, "finished")
	Sound.stop_ambience()
	get_tree().paused = false
	get_tree().change_scene("res://hud/mode-select/ModeSelect.tscn")
