extends Node

onready var world = get_tree().get_nodes_in_group("world")[0]


func _ready():
	var all_viewports = get_all_viewports()
	var all_cameras = get_all_cameras()
	var all_players = get_all_players()
	
	for viewport in all_viewports:
		viewport.world_2d = all_viewports[0].world_2d
		viewport.size = viewport.get_parent().rect_size
	for i in range(all_players.size()):
		all_cameras[i].target = all_players[i]


func get_all_viewports():
	return get_tree().get_nodes_in_group("viewport")


func get_all_cameras():
	return get_tree().get_nodes_in_group("viewport camera")


func get_all_players():
	var players = []
	
	for i in range(1, 5):
		var path = str("Players/Player", i)
		if world.has_node(path):
			players.append(world.get_node(path))
	
	return players
