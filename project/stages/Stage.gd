extends Node2D

const PLAYER = preload("res://player/Player.tscn")

var player_checkpoints = [0, 0, 0, 0]
var player_laps = [0, 0, 0, 0]


func setup(GameScene):
	var players = []
	var player_num = RoundManager.device_map.size()
	
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

func increase_player_checkpoint(Player):
	var player_num = int(Player.get_name()[-1])
	player_checkpoints[player_num - 1] += 1

func inscrease_player_lap(Player):
	var player_num = int(Player.get_name()[-1])
	player_laps[player_num - 1] += 1

func reset_player_checkpoint(Player):
	var player_num = int(Player.get_name()[-1])
	player_checkpoints[player_num - 1] = 0

func reset_player_lap(Player):
	var player_num = int(Player.get_name()[-1])
	player_laps[player_num - 1] = 0

func set_player_control(Player, index):
	var device = RoundManager.device_map[index]
	if device == "keyboard":
		Player.input_type = "Keyboard_mouse"
		Player.id = -1
	else:
		Player.input_type = "Gamepad"
		Player.id = int(device.split("_")[1])

func get_player_checkpoint(Player):
	var player_num = int(Player.get_name()[-1])
	
	return player_checkpoints[player_num - 1]

func get_player_lap(Player):
	var player_num = int(Player.get_name()[-1])
	
	return player_laps[player_num - 1]
