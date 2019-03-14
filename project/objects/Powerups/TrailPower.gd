extends Node2D

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
	yield($Timer, "timeout")
	player.create_trail = false
	queue_free()