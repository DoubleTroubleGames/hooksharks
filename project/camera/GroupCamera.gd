extends "res://camera/Camera.gd"

# All chidren of the Camera2D containing this script should be nodes inhereting from Node2D
# Needs a call of set_children() to work

export (float)var min_zoom = 1
export (float)var max_zoom = 0.5
export (int)var zooming_dist = 1000 # the camera will start zooming in when max_dist < zooming_dist
export (int)var min_dist = 100 # the camera will reach max_zoom at this dist

var children

func _ready():
	set_physics_process(false)


func _physics_process(delta):
	var max_dist = get_max_distance()
	
	if max_dist.x < zooming_dist:
		adjust_zoom(max_dist)
	
	set_position( get_average_position() )


func adjust_zoom(dist):
	var dist_x = clamp(dist.x, min_dist, zooming_dist)
	var weight_x = (dist_x - zooming_dist) / -(zooming_dist - min_dist)
	var x = lerp(min_zoom, max_zoom, weight_x)
	
	set_zoom(Vector2(x, x))


func get_average_position():
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