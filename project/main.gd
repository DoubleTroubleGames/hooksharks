extends Node2D

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()
