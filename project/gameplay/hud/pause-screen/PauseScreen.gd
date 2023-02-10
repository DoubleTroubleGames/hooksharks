extends CanvasLayer

onready var background = $Background
onready var buttons = [$Background/CenterContainer/VBoxContainer/Resume,
		$Background/CenterContainer/VBoxContainer/Quit]
onready var player_label = $Background/CenterContainer/VBoxContainer/HBoxContainer/Player

enum {RESUME, QUIT}

const DEADZONE = .55

var btn_index = 0
var player_device = "keyboard"
var players
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
		PauseManager.set_pause(false)


func change_button(direction):
	buttons[btn_index].set_texture(load(str("res://assets/images/ui/pause/", buttons[btn_index].get_name().to_lower(), ".png")))
	btn_index = wrapi(btn_index + direction, 0, buttons.size())
	buttons[btn_index].set_texture(load(str("res://assets/images/ui/pause/", buttons[btn_index].get_name().to_lower(), "_line.png")))
	$MenuSelectionSFX.play()


func press_button():
	$MenuConfirmSFX.play()
	match btn_index:
		RESUME:
			PauseManager.set_pause(false)
		QUIT:
			quit()


func quit():
	set_process_input(false)
	set_process(false)
	Transition.transition_in()
	Sound.stop_ambience()
	Sound.fade_out(Sound.battle_bgm, Sound.menu_bgm)
	
	yield(Transition, "finished")
	
	PauseManager.set_pause(false)
	get_tree().change_scene("res://menus/mode-select/ModeSelect.tscn")


func _allow_set_pause() -> bool:
	# PauseScreen will keep the game paused if an unpause attempt includes an
	# unpause_priority less than 0. This allows scripts that would otherwise
	# automatically unpause the game to leave that action to PauseScreen.
	if PauseManager.get_info().get("unpause_priority", 0) < 0:
		return false

	return true


func _on_set_pause(should_pause: bool) -> void:
	players = get_tree().get_nodes_in_group("players")
	if should_pause:
		var source_player = PauseManager.get_info().get("source_node", null)
		# Default to player 1 if the game wasn't paused by a player
		if not source_player in players:
			source_player = players[0]

		var color = RoundManager.CHAR_COLOR[RoundManager.character_map[source_player.id]]

		btn_index = 0
		for button in buttons:
			button.set_texture(load(str("res://assets/images/ui/pause/",
					button.get_name().to_lower(), ".png")))
		buttons[btn_index].set_texture(load(str("res://assets/images/ui/pause/",
				buttons[btn_index].get_name().to_lower(), "_line.png")))
		background.visible = true
		set_process_input(true)
		set_process(true)
		player_label.set_modulate(color)
		$Background/CenterContainer/VBoxContainer/HBoxContainer/Paused.set_modulate(color)
		player_device = source_player.device_name
		player_label.text = str("P", source_player.id + 1)
		$PauseOpenSFX.play()

	else:
		background.visible = false
		for player in players:
			player.update_input_map()
			player.apply_action_presses()

		set_process_input(false)
		set_process(false)
