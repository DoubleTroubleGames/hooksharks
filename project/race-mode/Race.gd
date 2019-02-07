extends "res://Game.gd"

func get_cameras():
	return get_parent().get_parent().get_parent().get_parent().get_all_cameras()