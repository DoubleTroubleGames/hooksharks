tool
extends Node2D

export(float) var whirl_size = 200 setget new_whirlpool_size
export(float) var death_size = 50 setget new_death_size

export(float) var pull_force = 2

func _ready():
	pass

func new_whirlpool_size(new_size):
	if $PullingWave and $PullingWave/CollisionShape2D:
		$PullingWave/CollisionShape2D.get_shape().radius = new_size
		whirl_size = new_size

func new_death_size(new_size):
	if $DeathZone and $DeathZone/CollisionShape2D:
		$DeathZone/CollisionShape2D.get_shape().radius = new_size
		death_size = new_size

func get_radius():
	return $PullingWave/CollisionShape2D.get_shape().radius

func get_applying_force(object):
	var our_pos = self.get_global_position()
	var their_pos = object.get_global_position()
	var dist = our_pos.distance_to(their_pos)
	var force = pull_force*(get_radius()/dist)
	
	return (our_pos - their_pos).normalized() * force