extends "res://Game.gd"

#export (NodePath)var SplitScreen = null

#func _ready():
#	$Camera2D.set_children($Players.get_children())

func get_cameras():
#	return get_node(SplitScreen).get_all_cameras()
	return [$Camera2D]
