class_name InfiniteDive
extends "res://gameplay/objects/powerups/GenericPower.gd"

var player

#const DURATION = 8

func init(_player):
	self.player = _player
	if not player.get_node("PowerUps").has_node("InfiniteDive"):
		activate()
		player.emit_signal("infinite_dive_started", self)
		return true
	else:
		player.emit_signal("infinite_dive_started", null)
		queue_free()
		return false


func activate():
	player.start_infinite_dive()


func deactivate():
	player.infinite_dive = false
	queue_free()
