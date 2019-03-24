extends Control


func _ready():
	set_process_input(false)
	
	Transition.transition_out()
	yield(Transition, "finished")
	
	set_process_input(true)
	$ArenaButton.disabled = false
	$RacingButton.disabled = false
	$ArenaButton.grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		transition_to("res://hud/main-menu/MainMenu.tscn")


func transition_to(scene_path):
	set_process_input(false)
	$ArenaButton.disabled = true
	$RacingButton.disabled = true
	
	Transition.transition_in()
	yield(Transition, "finished")
	get_tree().change_scene(scene_path)


func _on_ArenaButton_pressed():
	RoundManager.gamemode = "Arena"
	transition_to("res://hud/character-select/CharacterSelect.tscn")


func _on_RacingButton_pressed():
	RoundManager.gamemode = "Race"
	transition_to("res://hud/character-select/CharacterSelect.tscn")
