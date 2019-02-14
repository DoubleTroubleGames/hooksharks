extends Control

func _ready():
	$StartRace.grab_focus()


func _on_StartRace_pressed():
	$Click.play()
	get_tree().change_scene("res://splitscreen/SplitScreen.tscn")

func _on_StartArena_pressed():
	$Click.play()
	get_tree().change_scene("res://arena-mode/Arena.tscn")


func _on_Quit_pressed():
	get_tree().quit()