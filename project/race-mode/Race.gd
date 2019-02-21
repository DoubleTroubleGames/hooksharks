extends "res://Game.gd"

export (NodePath)var SplitScreen = null

func get_cameras():
	if SplitScreen:
		return get_node(SplitScreen).get_all_cameras()
	return [$Camera2D]