extends "res://Game.gd"

export (NodePath)var SplitScreen = null

func get_cameras():
	if SplitScreen:
		return get_node(SplitScreen).get_all_cameras()
	return [get_node("Stage/Camera2D")]

func connect_players():
	for player in players:
		player.connect("created_trail", self, "_on_player_created_trail")
		player.connect("hook_shot", self, "_on_player_hook_shot")
		player.connect("megahook_shot", self, "_on_player_megahook_shot")
		player.connect("died", self, "remove_player")
		player.connect("respawned", self, "respawn_player")
		for camera in Cameras:
			player.connect("shook_screen", camera, "add_shake")
	for camera in Cameras:
		camera.set_children(players)

func activate_players():
	for player in players:
		player.create_trail = false
		player.respawn = true
		player.ROT_SPEED = PI/2
		player.INITIAL_SPEED = 0
		player.ACC = 50
		player.MAX_SPEED = 500
		player.enable()

func respawn_player(player):
	var check_n = $Stage.get_player_checkpoint(player)
	if check_n > 0:
		$Stage.get_checkpoint(check_n)
	else:
		var start = $Stage.get_start_position(player.id + 1)
		player.position = start.position + start.get_parent().position
		player.rotation = start.direction.angle()
		player.speed2 = Vector2(cos(player.rotation), sin(player.rotation))
