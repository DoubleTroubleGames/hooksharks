extends "res://objects/Powerups/GenericPower.gd"

var player

func init(_player):
	self.player = _player
	if not player.get_node("PowerUps").has_node("InfiniteDive"):
		activate()
		return true
	else:
		queue_free()
		return false
		

func activate():
	player.start_infinite_dive()
	set_process(true)
	yield($Timer, "timeout")
	deactivate()

func deactivate():
	player.infinite_dive = false
	queue_free()


func _process(delta):
	self.position = player.position
	$Label.set_text("%.1f" % $Timer.time_left)
