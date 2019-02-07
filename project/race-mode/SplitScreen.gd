extends Node

onready var viewport1 = $Viewports/ViewportContainer1/Viewport
onready var viewport2 = $Viewports/ViewportContainer2/Viewport
onready var camera1 = $Viewports/ViewportContainer1/Viewport/Camera2D
onready var camera2 = $Viewports/ViewportContainer2/Viewport/Camera2D
onready var world = $Viewports/ViewportContainer1/Viewport/Race


func _ready():
	viewport2.world_2d = viewport1.world_2d
	camera1.target = world.get_node("Players/Player1")
	camera2.target = world.get_node("Players/Player2")


func connect_players_to_cameras():
	var all_players = get_all_players()
	var all_cameras = get_all_cameras()

	for camera in all_cameras:
		for player in all_players:
			player.connect("shook_screen", camera, "add_shake")
		world.get_node("HUD").connect("shook_screen", camera, "add_shake")


func get_all_players():
	var players = []
	
	for i in range(1, 4):
		var path = str("Players/Player", i)
		if world.has_node(path):
			players.append(world.get_node(path))
	
	return players


func get_all_cameras():
	var cams = []
	
	for i in range(1, 4):
		var path = str("Viewports/ViewportContainer", i, "/Viewport/Camera2D")
		if self.has_node(path):
			cams.append(get_node(path))
	
	return cams