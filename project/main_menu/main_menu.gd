extends Control

func _ready():
	$Menu/Start.grab_focus()


func _on_Start_pressed():
	global.scores = [0, 0]
	global.round_number = 1
	get_tree().change_scene("res://main.tscn")


func _on_Quit_pressed():
	get_tree().quit()
