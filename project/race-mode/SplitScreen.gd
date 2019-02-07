extends Node

onready var world = $Viewports/ViewportContainer1/Viewport/Race


func _ready():
	var all_viewports = get_all_viewports()
	var all_cameras = get_all_cameras()
	var all_players = get_all_players()
	
	for viewport in all_viewports:
		viewport.world_2d = all_viewports[0].world_2d
	for i in range(all_players.size()):
		all_cameras[i].target = all_players[i]


func get_all_viewports():
	var viewports = []
	
	for i in range(1, 5):
		var path = str("Viewports/ViewportContainer", i, "/Viewport")
		if self.has_node(path):
			viewports.append(get_node(path))
	
	return viewports


func get_all_players():
	var players = []
	
	for i in range(1, 5):
		var path = str("Players/Player", i)
		if world.has_node(path):
			players.append(world.get_node(path))
	
	return players


func get_all_cameras():
	var cams = []
	
	for i in range(1, 5):
		var path = str("Viewports/ViewportContainer", i, "/Viewport/Camera2D")
		if self.has_node(path):
			cams.append(get_node(path))
	
	return cams