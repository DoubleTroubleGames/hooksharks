extends "res://camera/Camera.gd"

# All chidren of the Camera2D containing this script should be nodes inhereting from Node2D
# Needs a call of set_children() to work

export (float)var max_zoom = 1.0

const CAM_MARGIN = 800
const MARGIN_MULTIPLIER = 1.6

var cam_margin = [Vector2(0, 0), Vector2(0, 0)] # top left and bottom right corners
var children


func _ready():
	set_physics_process(false)


func _physics_process(delta):
	set_position(lerp(get_position(), get_average_position(), .5))
	adjust_zoom()


func adjust_zoom():
	cam_margin = [children[0].get_global_position(), children[0].get_global_position()]
	for child in children:
		var pos = child.get_global_position()
		
		cam_margin[0].x = min(cam_margin[0].x, pos.x)
		cam_margin[1].x = max(cam_margin[1].x, pos.x)
		cam_margin[0].y = min(cam_margin[0].y, pos.y)
		cam_margin[1].y = max(cam_margin[1].y, pos.y)
		
	var max_margin = get_max_margin()
	var new_zoom
	
	max_margin[0] *= MARGIN_MULTIPLIER
	if max_margin[1] == "x":
		new_zoom = max_margin[0]/OS.get_window_size().x
	elif max_margin[1] == "y":
		new_zoom = max_margin[0]/OS.get_window_size().y
	new_zoom = max(new_zoom, max_zoom)
	new_zoom = lerp(get_zoom().x, new_zoom, 0.05)
	set_zoom(Vector2(new_zoom, new_zoom))


func get_max_margin():
	var c_pos = self.get_global_position()
	var mx = max(abs(c_pos.x - cam_margin[0].x), abs(c_pos.x - cam_margin[1].x))
	var my = max(abs(c_pos.y - cam_margin[0].y), abs(c_pos.y - cam_margin[1].y))
	
	if mx >= my:
		return [mx + CAM_MARGIN, "x"]
	else:
		return [my + CAM_MARGIN, "y"]


func get_average_position():
	if children.empty():
		return get_position()
	
	var avrg = children[0].get_position()
	
	for i in range(1, children.size()):
		avrg += children[i].get_position()
	avrg /= children.size()
	
	return avrg


func set_children(children):
	self.children = children
	set_physics_process(true)
