extends Node2D

const PLAYER = preload("res://player/Player.tscn")

var player_checkpoints = [0, 0, 0, 0]
var player_laps = [0, 0, 0, 0]


func _ready():
	if has_node("Camera2D"):
		var stage_size = Vector2($Camera2D.limit_right - $Camera2D.limit_left + 100, $Camera2D.limit_bottom - $Camera2D.limit_top + 100)
		$Water.rect_position.x = $Camera2D.limit_left - 50
		$Water.rect_position.y = $Camera2D.limit_top - 50
		$Water.rect_size = stage_size
		$Water._on_Water_resized()


func setup_players():
	var players = []
	
	for i in range(RoundManager.players_total):
		var start = get_start_position(i+1)
		var player = PLAYER.instance()
		
		player.position = start.position + start.get_parent().position
		player.initial_dir = start.direction
		player.rotation = start.direction.angle()
		player.id = i
		player.device_name = RoundManager.device_map[i]
		if RoundManager.character_map[i] == "Black":
			player.add_shark("Red")
			player.get_node("Shark").set_modulate(Color(0.1, 0.1, 0.1))
		else:
			player.add_shark(RoundManager.character_map[i])
		player.set_name(str("Player", i + 1))
		players.append(player)
		add_child(player)
	
	return players

func get_start_position(i):
	return get_node(str("PlayerStartingPosition/StartingPosition", i))
	

func increase_player_checkpoint(player):
	var player_num = int(player.get_name()[-1])
	player_checkpoints[player_num - 1] += 1


func increase_player_lap(player):
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

func get_checkpoint(n):
	for check in $Checkpoints.get_children():
		if check.number == n:
			return check
	assert(false)

func get_player_lap(player):
	var player_num = int(player.get_name()[-1])
	return player_laps[player_num - 1]
