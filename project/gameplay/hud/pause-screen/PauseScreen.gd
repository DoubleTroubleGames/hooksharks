extends CanvasLayer

onready var background = $Background
onready var buttons = [$Background/CenterContainer/VBoxContainer/Resume,
		$Background/CenterContainer/VBoxContainer/Quit]
onready var player_label = $Background/CenterContainer/VBoxContainer/HBoxContainer/Player

enum {RESUME, QUIT}

const DEADZONE = .55

var btn_index = 0
var player_device = "keyboard"
onready var _moved_up = false
onready var _moved_down = false

func _ready():
	set_process_input(false)
	set_process(false)

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
	buttons[btn_index].set_texture(load(str("res://assets/images/ui/pause/", buttons[btn_index].get_name().to_lower(), ".png")))
	btn_index = wrapi(btn_index + direction, 0, buttons.size())
	buttons[btn_index].set_texture(load(str("res://assets/images/ui/pause/", buttons[btn_index].get_name().to_lower(), "_line.png")))
	$MenuSelectionSFX.play()


func press_button():
	$MenuConfirmSFX.play()
	match btn_index:
		RESUME:
			unpause()
		QUIT:
			quit()


func pause(player):
	Sound.on_pause()
	var color = RoundManager.CHAR_COLOR[RoundManager.character_map[player.id]]
	
	btn_index = 0
	for button in buttons:
		button.set_texture(load(str("res://assets/images/ui/pause/",
				button.get_name().to_lower(), ".png")))
	buttons[btn_index].set_texture(load(str("res://assets/images/ui/pause/",
			buttons[btn_index].get_name().to_lower(), "_line.png")))
	get_tree().paused = true
	background.visible = true
	set_process_input(true)
	set_process(true)
	player_label.set_modulate(color)
	$Background/CenterContainer/VBoxContainer/HBoxContainer/Paused.set_modulate(color)
	player_device = player.device_name
	player_label.text = str("P", player.id + 1)
	$PauseOpenSFX.play()


func unpause():
	Sound.on_unpause()
	get_tree().paused = false
	background.visible = false
	set_process_input(false)
	set_process(false)


func quit():
	set_process_input(false)
	set_process(false)
	Transition.transition_in()
	Sound.stop_ambience()
	Sound.fade_out(Sound.game_bgm, Sound.menu_bgm)
	
	yield(Transition, "finished")
	
	get_tree().paused = false
	get_tree().change_scene("res://menus/mode-select/ModeSelect.tscn")
