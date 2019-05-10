extends Line2D

var hook = null
var player = null
var force = 500

func _physics_process(delta):
	if hook:
		var angle = Vector2(cos(player.sprite.rotation), sin(player.sprite.rotation))
		var rider_pos = player.position + player.rider_offset * angle
		self.set_point_position(0, rider_pos)
		self.set_point_position(1, hook.position)

func get_applying_force():
	return (get_point_position(1) - get_point_position(0)).normalized() * force
