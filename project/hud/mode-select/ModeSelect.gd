extends Control


func _ready():
	$ArenaButton.grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://hud/main-menu/MainMenu.tscn")


func _on_ArenaButton_pressed():
	RoundManager.gamemode = "Arena"
	get_tree().change_scene("res://hud/character-select/CharacterSelect.tscn")


func _on_RacingButton_pressed():
	RoundManager.gamemode = "Race"
	get_tree().change_scene("res://hud/character-select/CharacterSelect.tscn")
