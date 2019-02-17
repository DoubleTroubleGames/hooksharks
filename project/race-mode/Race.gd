extends "res://Game.gd"

export (NodePath)var SplitScreen = null

func get_cameras():
	if SplitScreen:
		return get_node(SplitScreen).get_all_cameras()
	return [$Camera2D]

func connect_players():
	for player in players:
		player.connect("created_trail", self, "_on_player_created_trail")
		player.connect("hook_shot", self, "_on_player_hook_shot")
		player.connect("died", self, "remove_player")
		for camera in Cameras:
			player.connect("shook_screen", camera, "add_shake")
	for camera in Cameras:
		camera.set_children(players)