extends Node

export (int, 2, 4)var player_num = 2

onready var world = get_tree().get_nodes_in_group("world")[0]


func _ready():
	create_viewports()
	set_viewports_size()
	var all_viewports = get_all_viewports()
	var all_cameras = get_all_cameras()
	var all_players = get_all_players()
	
	for viewport in all_viewports:
		viewport.world_2d = all_viewports[0].world_2d
		viewport.size = viewport.get_parent().rect_size
#	for i in range(all_players.size()):
#		all_cameras[i].target = all_players[i]
	all_cameras[0].target = all_players[0]


func create_viewports():
	for i in range(2, player_num + 1):
		var ViewCont = ViewportContainer.new()
		var View = Viewport.new()
		var Cam = Camera2D.new()
		
		ViewCont.set_name(str("ViewportContainer", i))
		ViewCont.margin_right = 1280
		ViewCont.margin_bottom = 720
		ViewCont.add_child(View)
		
		View.add_to_group("viewport")
		View.add_child(Cam)
		
		Cam.add_to_group("viewport camera")
		Cam.current = true
		Cam.set_position(Vector2(600, 300)) # Remove when fix camera tracking
		
		self.add_child(ViewCont)


func define_viewport_position(current_viewport_index):
	var i = current_viewport_index
	
	if player_num > 2:
		var pos = Vector2((i % 2) * 640, 0)
		
		if i > 1:
			pos.y = 360
		return pos
	else:
		return Vector2(0, i * 360)


func set_viewports_size():
	var size = Vector2(640, 360)
	var viewports = get_all_viewports()
	
	if player_num == 2:
		size = Vector2(1280, 360)
	
	for i in range(viewports.size()):
		var ViewCont = viewports[i].get_parent()
		
		viewports[i].set_size(size)
		ViewCont.rect_position = define_viewport_position(i)
		ViewCont.set_size(size)


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
