extends Control

func _ready():
	$StartRace.grab_focus()


func _on_StartRace_pressed():
	$Click.play()
	RoundManager.gamemode = "Race"
	get_tree().change_scene("res://character-select/CharacterSelect.tscn")

func _on_StartArena_pressed():
	$Click.play()
	RoundManager.gamemode = "Arena"
	get_tree().change_scene("res://character-select/CharacterSelect.tscn")

func _on_Quit_pressed():
	get_tree().quit()
