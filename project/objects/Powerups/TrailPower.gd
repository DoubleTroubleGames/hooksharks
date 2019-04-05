extends "res://objects/Powerups/GenericPower.gd"

var player

func init(_player):
	self.player = _player
	if not player.get_node("PowerUps").has_node("PowerTrail"):
		activate()
		return true
	else:
		queue_free()
		return false
		

func activate():
	player.create_trail = true
	set_process(true)
	yield($Timer, "timeout")
	player.create_trail = false
	queue_free()


func _process(delta):
	$Label.set_text("%.1f" % $Timer.time_left)
