extends Control

func _ready():
	$ArenaButton.grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://main-menu/MainMenu.tscn")


func next_screen():
	get_tree().change_scene("res://hud/character-select/CharacterSelect.tscn")


func _on_ArenaButton_pressed():
	RoundManager.gamemode = "Arena"
	next_screen()


func _on_RacingButton_pressed():
	RoundManager.gamemode = "Race"
	next_screen()
