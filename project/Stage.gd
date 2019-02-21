extends Node2D

const PLAYER = preload("res://player/Player.tscn")


func setup(GameScene, player_num):
	var players = []
	
	for i in range(1, player_num + 1):
		var StartPos = get_node(str("PlayerStartingPosition/StartingPosition", i))
		var Player = PLAYER.instance()
		
		Player.set_position(StartPos.position)
		Player.initial_dir = StartPos.direction
		Player.set_name(str("Player", i))
		Player.id = i - 1
		GameScene.players.append(Player)
		add_child(Player)
	
	get_node("PlayerStartingPosition").queue_free()

