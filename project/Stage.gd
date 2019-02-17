extends Node2D

const PLAYER = preload("res://player/Player.tscn")

func setup(GameScene, player_num):
	for i in range(1, player_num + 1):
		var StartPos = get_node(str("PlayerStartingPosition/StartingPosition", i))
		var Player = PLAYER.instance()
		
		Player.set_position(StartPos.position)
		Player.initial_dir = StartPos.direction
		Player.get_node("Sprite").set_texture(load("res://player/sprite_sheet_v02.png"))
		Player.set_name(str("Player", i))
		Player.id = i - 1
		GameScene.players.append(Player)
		add_child(Player)
	
	get_node("PlayerStartingPosition").queue_free()