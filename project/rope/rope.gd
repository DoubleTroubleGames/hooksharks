extends Line2D

var hook = null
var player = null

func _physics_process(delta):
	self.set_point_position(0, hook.position)
	self.set_point_position(1, player.position)
