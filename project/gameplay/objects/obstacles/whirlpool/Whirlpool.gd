tool
extends Node2D

const ROTATE_RATIO = .6

export(float) var whirl_size = 200 setget new_whirlpool_size
export(float) var death_size = 50 setget new_death_size
export(bool) var clockwise = true setget new_direction
export(float) var pull_force = 2
export(float) var rotate_force = 1


func _ready():
	pass

func _physics_process(delta):
	if clockwise:
		$Waves.rotation = $Waves.rotation + pull_force*rotate_force*ROTATE_RATIO*delta
	else:
		$Waves.rotation = $Waves.rotation - pull_force*rotate_force*ROTATE_RATIO*delta
		
func new_direction(clock):
	if clock:
		$Waves.scale.x = abs($Waves.scale.x)
	else:
		$Waves.scale.x = -abs($Waves.scale.x)
	clockwise = clock

func scale_sprite(sprite):
	var sprite_size = sprite.get_rect().size
	var w = 2*whirl_size/sprite_size.x
	var h = 2*whirl_size/sprite_size.y
	sprite.scale = Vector2(w, h)

func update_death_shader():
	var value = death_size/whirl_size
	print(value)
	$WaterEffect.get_material().set_shader_param("death_edge", value)

func new_whirlpool_size(new_size):
	if $PullingWave and $PullingWave/CollisionShape2D:
		whirl_size = new_size
		$PullingWave/CollisionShape2D.get_shape().radius = new_size
		scale_sprite($Waves)
		scale_sprite($WaterEffect)
		update_death_shader()
		$WaterEffect.update()

func new_death_size(new_size):
	if $DeathZone and $DeathZone/CollisionShape2D:
		$DeathZone/CollisionShape2D.get_shape().radius = new_size
		death_size = new_size
		update_death_shader()

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