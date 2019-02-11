extends "res://Game.gd"

export (NodePath)var SplitScreen = null


func get_cameras():
	return get_node(SplitScreen).get_all_cameras()
