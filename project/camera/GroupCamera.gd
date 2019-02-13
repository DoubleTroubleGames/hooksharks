extends "res://camera/Camera.gd"

# All chidren of the Camera2D containing this script should be nodes inhereting from Node2D

onready var children = get_children()


func _process(delta):
	set_position( get_average_position() )


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
			var dist = children[i].get_position().distance_to( children[j].get_position() )
			
			if dist.x > max_dist.x:
				max_dist.x = dist.x
			if dist.y > max_dist.y:
				max_dist.y = dist.y
	
	return max_dist