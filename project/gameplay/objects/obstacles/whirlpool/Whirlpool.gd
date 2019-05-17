tool
extends Node2D

export(float) var whirl_size = 200 setget new_whirlpool_size
export(float) var death_size = 50 setget new_death_size
export(bool) var clockwise = true
export(float) var pull_force = 2
export(float) var rotate_force = 1

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
	
	var factor = 1 - min(pow(dist/get_radius(), 4), 1.0)
	
	var force = pull_force * factor
	var pulling_force = (our_pos - their_pos).normalized() * force
	
	force = rotate_force * factor
	var rotation_force
	if clockwise:
		rotation_force = (our_pos - their_pos).normalized().rotated(-PI/2) * force
	else:
		rotation_force = (our_pos - their_pos).normalized().rotated(PI/2) * force
		
	return pulling_force + rotation_force