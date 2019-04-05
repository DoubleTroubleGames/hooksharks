tool

extends Node2D

export (Vector2)var stage_begin = Vector2(-1500, -900) setget set_stage_begin
export (Vector2)var stage_end = Vector2(2200, 1400) setget set_stage_end

const PLAYER = preload("res://player/Player.tscn")

var player_checkpoints = [0, 0, 0, 0]
var player_laps = [0, 0, 0, 0]


func _ready():
	resize_water()


func resize_water():
	$Water.rect_position.x = stage_begin.x
	$Water.rect_position.y = stage_begin.y
	$Water.rect_size = stage_end - stage_begin
	$Water._on_Water_resized()


func setup_players():
	var players = []
	
	for i in range(RoundManager.players_total):
		var start = get_start_position(i+1)
		var player = PLAYER.instance()
		
		player.position = start.position + start.get_parent().position
		player.initial_dir = start.direction
		player.id = i
		player.device_name = RoundManager.device_map[i]
		player.add_shark(RoundManager.character_map[i])
		player.set_name(str("Player", i + 1))
		players.append(player)
		add_child(player)
	
	return players


func set_stage_begin(pos):
	stage_begin = pos
	resize_water()


func set_stage_end(pos):
	stage_end = pos
	resize_water()


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
