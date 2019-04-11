extends CanvasLayer

onready var background = $Background
onready var buttons = [$Background/CenterContainer/VBoxContainer/Resume,
		$Background/CenterContainer/VBoxContainer/Quit]
onready var player_label = $Background/CenterContainer/VBoxContainer/HBoxContainer/Player

enum {RESUME, QUIT}

const UNSELECTED_COLOR = Color(1, 1, 1)
const SELECTED_COLOR = Color(1, 1, .5)

var btn_index = 0
var player_device = "keyboard"

func _ready():
	buttons[btn_index].modulate = SELECTED_COLOR
	set_process_input(false)


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
	get_tree().paused = true
	background.visible = true
	set_process_input(true)
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
	get_tree().change_scene("res://hud/mode-select/ModeSelect.tscn")
