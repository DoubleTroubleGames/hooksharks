extends Node

export (int, 2, 4)var player_num = 2

onready var world = get_tree().get_nodes_in_group("world")[0]


func _ready():
	create_viewports()
	var all_viewports = get_all_viewports()
	var all_cameras = get_all_cameras()
	var all_players = get_all_players()
	
	yield(all_cameras[-1], "tree_entered") # waits for last viewport's Camera to be ready
	
	for viewport in all_viewports:
		viewport.world_2d = all_viewports[0].world_2d
		viewport.size = viewport.get_parent().rect_size
	for i in range(all_players.size()):
		all_cameras[i].target = all_players[i]


func create_viewports():
	for i in range(2, player_num + 1):
		var ViewCont = ViewportContainer.new()
		var View = Viewport.new()
		var Cam = Camera2D.new()
		
		ViewCont.set_name(str("ViewportContainer", i))
		ViewCont.add_child(View)
		View.add_child(Cam)
		
		View.add_to_group("viewport")
		Cam.add_to_group("viewport camera")
		Cam.current = true
		
		self.add_child(ViewCont)


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
