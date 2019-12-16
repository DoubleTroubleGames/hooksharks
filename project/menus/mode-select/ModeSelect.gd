extends Control

onready var _moved_left = false
onready var _moved_right = false
onready var _moved_up = false
onready var _moved_down = false

const WAVE_LENGTH = 0.8
const SPEED = 5

func _ready():
	set_process(true)
	set_process_input(false)
	
	Transition.transition_out()
	yield(Transition, "finished")
	
	set_process_input(true)
	$ArenaButton.disabled = false
	$RacingButton.disabled = false
	$OptionsButton.disabled = false
	$RacingButton.disabled = false
	$ArenaButton.grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		transition_to("res://menus/main-menu/MainMenu.tscn")

func _process(delta):
	if not _moved_left and Input.is_action_just_pressed("ui_joy_left"):
		_moved_left = true
		var cur_focus = self.get_focus_owner()
		if cur_focus and cur_focus.focus_neighbour_left:
			cur_focus.get_node(cur_focus.focus_neighbour_left).grab_focus()
	if not _moved_right and Input.is_action_just_pressed("ui_joy_right"):
		_moved_right = true
		var cur_focus = self.get_focus_owner()
		if cur_focus and cur_focus.focus_neighbour_right:
			cur_focus.get_node(cur_focus.focus_neighbour_right).grab_focus()
	if not _moved_up and Input.is_action_just_pressed("ui_joy_up"):
		_moved_up = true
		var cur_focus = self.get_focus_owner()
		if cur_focus and cur_focus.focus_neighbour_top:
			cur_focus.get_node(cur_focus.focus_neighbour_top).grab_focus()
	if not _moved_down and Input.is_action_just_pressed("ui_joy_down"):
		_moved_down = true
		var cur_focus = self.get_focus_owner()
		if cur_focus and cur_focus.focus_neighbour_bottom:
			cur_focus.get_node(cur_focus.focus_neighbour_bottom).grab_focus()
	if _moved_left and Input.is_action_just_released("ui_joy_left"):
		_moved_left = false
	if _moved_right and Input.is_action_just_released("ui_joy_right"):
		_moved_right = false
	if _moved_up and Input.is_action_just_released("ui_joy_up"):
		_moved_up = false
	if _moved_down and Input.is_action_just_released("ui_joy_down"):
		_moved_down = false

func transition_to(scene_path):
	set_process_input(false)
	$ArenaButton.disabled = true
	$RacingButton.disabled = true
	$OptionsButton.disabled = true
	$RacingButton.disabled = true
	
	Transition.transition_in()
	yield(Transition, "finished")
	get_tree().change_scene(scene_path)


func _on_ArenaButton_pressed():
	RoundManager.gamemode = "Arena"
	$Sounds/ConfirmSFX.play()
	transition_to("res://menus/character-select/CharacterSelect.tscn")


func _on_RacingButton_pressed():
	RoundManager.gamemode = "Race"
	$Sounds/ConfirmSFX.play()
	transition_to("res://menus/character-select/CharacterSelect.tscn")

func _on_OptionsButton_pressed():
	$Sounds/ConfirmSFX.play()
	transition_to("res://menus/options-menu/OptionsMenu.tscn")


func _on_CreditsButton_pressed():
	$Sounds/ConfirmSFX.play()
	#transition_to("killme.tscn")

func _on_ArenaButton_focus_entered():
	fadeWaveIn($ArenaButton)
	
	fadeWaveOut($RacingButton)
	fadeWaveOut($CreditsButton)
	fadeWaveOut($OptionsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()

func _on_RacingButton_focus_entered():
	fadeWaveIn($RacingButton)
	
	fadeWaveOut($ArenaButton)
	fadeWaveOut($CreditsButton)
	fadeWaveOut($OptionsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()

func _on_OptionsButton_focus_entered():
	fadeWaveIn($OptionsButton)
	
	fadeWaveOut($ArenaButton)
	fadeWaveOut($RacingButton)
	fadeWaveOut($CreditsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()


func _on_CreditsButton_focus_entered():
	fadeWaveIn($CreditsButton)
	
	fadeWaveOut($ArenaButton)
	fadeWaveOut($RacingButton)
	fadeWaveOut($OptionsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()
	
func fadeWaveIn(button):
	var cur = button.get_material().get_shader_param("wave_length")
	if cur < WAVE_LENGTH:
		$Tween.interpolate_property(button.get_material(), 
	                           "shader_param/wave_length", 
	                           cur, WAVE_LENGTH, (WAVE_LENGTH-cur)/SPEED, 
	                           Tween.TRANS_LINEAR, Tween.EASE_OUT)
func fadeWaveOut(button):
	var cur = button.get_material().get_shader_param("wave_length")
	if cur > 0:
		$Tween.interpolate_property(button.get_material(), 
	                    "shader_param/wave_length", 
	                    cur, 0, cur/SPEED, 
	                    Tween.TRANS_LINEAR, Tween.EASE_OUT)
