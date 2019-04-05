extends "res://Game.gd"

export (NodePath)var SplitScreen = null

const RESPAWN_TIME = 2.0


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
		set_race_attributes(player)
		player.enable()


func set_race_attributes(player):
	player.create_trail = false
	player.respawn = true
	player.ROT_SPEED = PI/2
	player.INITIAL_SPEED = 1
	player.ACC = 50
	player.MAX_SPEED = 500


func respawn_player(player):
	var check_n = $Stage.get_player_checkpoint(player)
	var RespTimer = player.get_node("RespawnTimer")
	var final_position
	var final_rotation
	player.reset_input_map()
	player.can_dive = true
	if check_n > 0:
		var check = $Stage.get_checkpoint(check_n)
		final_position = check.get_respawn_position(player.id + 1)
		final_rotation = check.rotation
	else:
		var start = $Stage.get_start_position(player.id + 1)
		final_position = start.position + start.get_parent().position
		final_rotation = start.direction.angle()
	
	RespTimer.wait_time = RESPAWN_TIME
	RespTimer.start()
	$Tween.interpolate_property(player, "global_position", null, final_position, RESPAWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(player.sprite, "rotation", null, final_rotation, RESPAWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield(RespTimer, "timeout")
	player.sprite_animation.play("idle")
	player.sprite.set_modulate(Color(1, 1, 1, 1))
	player.enable()
	player.speed2 = Vector2(200 * cos(player.sprite.rotation), 200 *  sin(player.sprite.rotation))
