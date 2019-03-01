extends Node2D

const PLAYER = preload("res://player/Player.tscn")


func setup(GameScene):
	var players = []
	var player_num = RoundManager.device_map.size()
	
	for i in range(player_num):
		var start = get_node(str("PlayerStartingPosition/StartingPosition", i + 1))
		var player = PLAYER.instance()
		
		player.position = start.position
		player.initial_dir = start.direction
		player.rotation = start.direction.angle()
		player.id = i
		player.device_name = RoundManager.device_map[i]
		player.set_name(str("Player", i + 1))
		set_player_control(player, i)
		GameScene.players.append(player)
		add_child(player)
	
	get_node("PlayerStartingPosition").queue_free()
