extends Node2D

enum GAME_MODE { arena, race }
export(GAME_MODE) var game_mode = GAME_MODE.arena

const PLAYER = preload("res://player/Player.tscn")

func setup(GameScene, player_num):
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

func get_game_mode():
	return game_mode

func activate_players(players):
	for player in players:
		player.get_node("Area2D").monitoring = true
		player.set_physics_process(true)
		print(game_mode, GAME_MODE.arena)
		if game_mode == GAME_MODE.race:
			print("did")
			player.create_trail = false

func connect_players(players, cameras):
	for player in players:
		player.connect("created_trail", self, "_on_player_created_trail")
		player.connect("hook_shot", self, "_on_player_hook_shot")
		player.connect("died", self, "remove_player")
		for camera in cameras:
			player.connect("shook_screen", camera, "add_shake")
	if game_mode == GAME_MODE.race:
		for camera in cameras:
			camera.set_children(players)