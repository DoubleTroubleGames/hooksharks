extends Node2D

const PLAYER = preload("res://player/Player.tscn")


func setup(GameScene):
	var players = []
	var player_num = RoundManager.device_map.size()
	print(RoundManager.device_map)
	
	for i in range(1, player_num + 1):
		var StartPos = get_node(str("PlayerStartingPosition/StartingPosition", i))
		var Player = PLAYER.instance()
		
		Player.set_position(StartPos.position)
		Player.initial_dir = StartPos.direction
		Player.set_name(str("Player", i))
		set_player_control(Player, i - 1)
		GameScene.players.append(Player)
		add_child(Player)
	
	get_node("PlayerStartingPosition").queue_free()

func set_player_control(Player, index):
	var device = RoundManager.device_map[index]
	if device == "keyboard":
		Player.input_type = "Keyboard_mouse"
		Player.id = -1
	else:
		Player.input_type = "Gamepad"
		Player.id = int(device.split("_")[1])