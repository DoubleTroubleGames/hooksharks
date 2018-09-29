extends Line2D

var hook = null
var player = null
var force = 700

func _physics_process(delta):
	self.set_point_position(0, player.position)
	self.set_point_position(1, hook.position)

func get_applying_force():
	return (get_point_position(1) - get_point_position(0)).normalized() * force
