extends Control

func _ready():
	$StartRace.grab_focus()


func _on_StartRace_pressed():
	pass # replace with function body


func _on_StartArena_pressed():
	BGM.get_node('Click').play()
	get_tree().change_scene("res://Main.tscn")


func _on_Quit_pressed():
	get_tree().quit()