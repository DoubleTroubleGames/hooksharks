extends Control

func _ready():
	$Start.grab_focus()

func _on_Start_pressed():
	Bgm.get_node('Click').play()
	get_tree().change_scene("res://main.tscn")

func _on_Quit_pressed():
	get_tree().quit()
