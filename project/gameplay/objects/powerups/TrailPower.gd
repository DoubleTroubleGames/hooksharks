class_name TrailPower
extends "res://gameplay/objects/powerups/GenericPower.gd"

var player

#const DURATION = 4

func init(_player):
	self.player = _player
	if not player.get_node("PowerUps").has_node("PowerTrail"):
		activate()
		player.emit_signal("fire_trail_started", self)
		return true
	else:
		player.emit_signal("fire_trail_started", null)
		queue_free()
		return false


func activate():
	player.create_trail = true


func deactivate():
	player.create_trail = false
	queue_free()
