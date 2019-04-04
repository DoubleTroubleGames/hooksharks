extends "res://camera/Camera.gd"

# All chidren of the Camera2D containing this script should be nodes inhereting from Node2D
# Needs a call of set_children() to work

export (float)var max_zoom = 1.0

const CAM_MARGIN = 200

var cam_margin = [Vector2(0, 0), Vector2(0, 0)] # top left and bottom right corners
var children


func _ready():
	set_physics_process(true)


func _physics_process(delta):
	set_position(lerp(get_position(), get_average_position(), .5))
	adjust_zoom()


func adjust_zoom():
	cam_margin = [children[0].get_global_position(), children[0].get_global_position()]
	for child in children:
		var pos = child.get_global_position()
		
		if pos.x < cam_margin[0].x:
			cam_margin[0].x = pos.x
		if pos.x > cam_margin[1].x:
			cam_margin[1].x = pos.x
		if pos.y < cam_margin[0].y:
			cam_margin[0].y = pos.y
		if pos.y > cam_margin[1].y:
			cam_margin[1].y = pos.y
		
	var max_dist = Vector2(abs(cam_margin[1].x - cam_margin[0].x), abs(cam_margin[1].y - cam_margin[0].y))
	var new_zoom
	
	if max_dist.x > max_dist.y:
		new_zoom = (max_dist.x + CAM_MARGIN)/OS.get_screen_size().x
	else:
		new_zoom = (max_dist.y + CAM_MARGIN)/OS.get_screen_size().y
	new_zoom = lerp(get_zoom().x, new_zoom, 0.2)
	
	if new_zoom > max_zoom:
		set_zoom(Vector2(new_zoom, new_zoom))
	else:
		set_zoom(Vector2(max_zoom, max_zoom))

func get_average_position():
	if children.empty():
		return get_position()
	
	var avrg = children[0].get_position()
	
	for i in range(1, children.size()):
		avrg += children[i].get_position()
	avrg /= children.size()
	
	return avrg


func get_max_distance():
	var max_dist = Vector2(0, 0)
	
	for i in range(children.size() - 1):
		for j in range(i + 1, children.size()):
			var pos1 = children[i].get_position()
			var pos2 = children[j].get_position()
			var dist = Vector2(abs(pos1.x - pos2.x), abs(pos1.y - pos2.y))
			
			if dist.x > max_dist.x:
				max_dist.x = dist.x
			if dist.y > max_dist.y:
				max_dist.y = dist.y
	
	return max_dist


func set_children(children):
	self.children = children
	set_physics_process(true)
