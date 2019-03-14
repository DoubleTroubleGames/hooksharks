extends Node2D

const PLAYER = preload("res://player/Player.tscn")

var player_checkpoints = [0, 0, 0, 0]
var player_laps = [0, 0, 0, 0]


func _ready():
	if has_node("Camera2D"):
		var stage_size = Vector2($Camera2D.limit_right, $Camera2D.limit_bottom)
		$Water.rect_size = stage_size

func setup_players():
	var players = []
	
	for i in range(RoundManager.players_total):
		var start = get_node(str("PlayerStartingPosition/StartingPosition", i + 1))
		var player = PLAYER.instance()
		
		player.position = start.position
		player.initial_dir = start.direction
		player.rotation = start.direction.angle()
		player.id = i
		player.device_name = RoundManager.device_map[i]
		player.get_node("Sprite").set_modulate(RoundManager.color_map[i])
		player.set_name(str("Player", i + 1))
		players.append(player)
		add_child(player)
	
	get_node("PlayerStartingPosition").queue_free()
	
	return players


func increase_player_checkpoint(player):
	var player_num = int(player.get_name()[-1])
	player_checkpoints[player_num - 1] += 1


func inscrease_player_lap(player):
	var player_num = int(player.get_name()[-1])
	player_laps[player_num - 1] += 1


func reset_player_checkpoint(player):
	var player_num = int(player.get_name()[-1])
	player_checkpoints[player_num - 1] = 0


func reset_player_lap(player):
	var player_num = int(player.get_name()[-1])
	player_laps[player_num - 1] = 0


func get_player_checkpoint(player):
	var player_num = int(player.get_name()[-1])
	
	return player_checkpoints[player_num - 1]


func get_player_lap(player):
	var player_num = int(player.get_name()[-1])
	
	return player_laps[player_num - 1]
