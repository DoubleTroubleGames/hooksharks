tool

extends Node2D

export (Vector2)var stage_begin = Vector2(-1500, -900) setget set_stage_begin
export (Vector2)var stage_end = Vector2(2200, 1400) setget set_stage_end
export (String)var stage_name = "Sample Name"
export (Color)var water_border = Color("0f4676") setget set_water_border
export (Color)var water_deep = Color("0a2f4f") setget set_water_deep
export (Color)var water_foam = Color("25628b") setget set_water_foam

const PLAYER = preload("res://gameplay/player/Player.tscn")
const CAMERA_RATIO = .07

var player_checkpoints = [null, null, null, null]
var player_laps = [0, 0, 0, 0]


func _ready():
	resize_water()
	color_water()
	resize_camera()


func resize_water():
	$Water.rect_position.x = stage_begin.x
	$Water.rect_position.y = stage_begin.y
	$Water.rect_size = stage_end - stage_begin
	$Water._on_Water_resized()

func resize_camera():
	if has_node("Camera2D"):
		var w = stage_end.x - stage_begin.x
		var h = stage_end.y - stage_begin.y
		$Camera2D.limit_left = stage_begin.x + CAMERA_RATIO*w
		$Camera2D.limit_right = stage_end.x - CAMERA_RATIO*w
		$Camera2D.limit_top = stage_begin.y + CAMERA_RATIO*h
		$Camera2D.limit_bottom = stage_end.y - CAMERA_RATIO*h
	
func set_water_border(value):
	water_border = value
	color_water()

func set_water_deep(value):
	water_deep = value
	color_water()

func set_water_foam(value):
	water_foam = value
	color_water()

func color_water():
	$Water/BG.get_material().set_shader_param("deep_color", water_deep)
	$Water/BG.get_material().set_shader_param("shallow_color", water_border)
	$Water/Waves.get_material().set_shader_param("wave_color", water_foam)
	var shader = load("res://gameplay/objects/obstacles/solid-objects/outline_final.tres")
	shader.set_shader_param("wave_color", water_foam)

func get_stage_name():
	return stage_name
	
func get_stage_laps():
	if has_node("FinishLine"):
		return $FinishLine.get_laps()
	else:
		return null

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
		if has_node("FinishLine"):
			player_checkpoints[i] = $FinishLine
		elif RoundManager.gamemode == "Race":
			print("This should not happen")
			assert(false)
		add_child(player)
	
	return players


func set_stage_begin(pos):
	stage_begin = pos
	resize_water()
	resize_camera()


func set_stage_end(pos):
	stage_end = pos
	resize_water()
	resize_camera()


func get_start_position(i):
	return get_node(str("PlayerStartingPosition/StartingPosition", i))
	

func update_player_checkpoint(player, checkpoint):
	var player_num = int(player.get_name()[-1])
	player_checkpoints[player_num - 1] = checkpoint


func increase_player_lap(player):
	var player_num = int(player.get_name()[-1])
	player_laps[player_num - 1] += 1


func reset_player_checkpoint(player):
	var player_num = int(player.get_name()[-1])
	player_checkpoints[player_num - 1] = $FinishLine


func reset_player_lap(player):
	var player_num = int(player.get_name()[-1])
	player_laps[player_num - 1] = 0


func get_player_checkpoint(player):
	var player_num = int(player.get_name()[-1])
	return player_checkpoints[player_num - 1]

func get_player_lap(player):
	var player_num = int(player.get_name()[-1])
	return player_laps[player_num - 1]
