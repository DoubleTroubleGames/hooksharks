extends Node2D

signal created_trail(trail)
signal died(player, is_player_collision)
signal hook_shot(player, direction)
signal shook_screen(amount)

const ROT_SPEED = PI/3.5
const TRAIL = preload("res://player/Trail.tscn")
const ACC = 4
const INITIAL_SPEED = 100
const AXIS_DEADZONE = .2
const DIVE_PARTICLES = preload("res://fx/DiveParticles.tscn")
const EXPLOSIONS = [preload("res://player/explosion/1.png"),
		preload("res://player/explosion/2.png"),
		preload("res://player/explosion/3.png"),
		preload("res://player/explosion/4.png")]
const SCREEN_SHAKE_EXPLOSION = 1

onready var arrow = $Arrow
onready var bar = $DiveCooldown/Bar
onready var dive_bar = $DiveCooldown
onready var sprite = $Sprite
onready var sprite_animation = $Sprite/AnimationPlayer
onready var area = $Area2D
onready var tween = $Tween

export(int, -1, 3) var id
export(Vector2) var initial_dir = Vector2(1, 0)
export(String, "Keyboard_mouse", "Gamepad") var input_type = "Keyboard_mouse"
export(bool) var create_trail = true

var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()
var diving = false
var can_dive = true
var dive_cooldown = 1.5
var stunned = false
var hook = null
var pull_dir = null
var speed2 = Vector2(INITIAL_SPEED, 0)


func _ready():
	speed2 = speed2.rotated(initial_dir.angle())
	$Explosion.texture = EXPLOSIONS[randi() % 4]
	$Explosion2.texture = EXPLOSIONS[randi() % 4]
	$DiveCooldown/CooldownTimer.connect('timeout', self, 'enable_diving')


func _physics_process(delta):
	speed2 += speed2.normalized() * ACC * delta
	var applying_force = Vector2(0, 0)

	if hook != null and weakref(hook).get_ref() and hook.is_colliding()\
			and not hook.is_pulling_object():
		applying_force = hook.rope.get_applying_force()
	elif not stunned:
		if input_type == "Keyboard_mouse":
			if Input.is_action_pressed("ui_right"):
				speed2 = speed2.rotated(ROT_SPEED * delta)
			if Input.is_action_pressed("ui_left"):
				speed2 = speed2.rotated(-ROT_SPEED * delta)
		elif input_type == "Gamepad":
			if Input.get_joy_axis(id, 0) > AXIS_DEADZONE and not stunned:
				speed2 = speed2.rotated(ROT_SPEED * delta)
			if Input.get_joy_axis(id, 0) < -AXIS_DEADZONE and not stunned:
				speed2 = speed2.rotated(-ROT_SPEED * delta)
	
	var proj = (applying_force.dot(speed2) / speed2.length_squared()) * speed2
	applying_force -= proj
	
	if stunned:
		position += pull_dir * 100 * delta
		applying_force = pull_dir * 200
	
	position += speed2 * delta
	speed2 += applying_force * delta
	
	rotation = speed2.angle()
	
	if self.create_trail and self.position.distance_to(last_trail_pos) > 2 * trail.get_node('Area2D/CollisionShape2D').get_shape().radius:
		if not diving:
			create_trail(self.position)
	
	# Update arrow direction
	var arrow_dir = get_arrow_direction()
	arrow.visible = (arrow_dir.length() > AXIS_DEADZONE and !diving)
	arrow.global_rotation = arrow_dir.angle()
	
	dive_bar.global_rotation = 0

func get_arrow_direction():
	match input_type:
		"Gamepad":
			return Vector2(Input.get_joy_axis(id, 2), Input.get_joy_axis(id, 3))
		"Keyboard_mouse":
			return get_global_mouse_position() - get_position()
	
	print("input_type not defined")
	return Vector2()

func create_trail(pos):
	var trail = TRAIL.instance()
	trail.position = pos
	trail.rotation = speed2.angle()
	last_trail_pos = trail.position
	emit_signal("created_trail", trail)

func _on_Area2D_area_exited(area):
	var object = area.get_parent()
	if object.is_in_group('trail'):
		object.can_collide = true

func _on_Area2D_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('trail') and object.can_collide and not diving:
		_queue_free()
	if object.is_in_group('wall'):
		_queue_free()
	if object.is_in_group('player') and object != self:
		if diving == object.diving:
			_queue_free(true)

func _queue_free(is_player_collision=false):
	$Explosion.emitting = true
	$Explosion2.emitting = true
	sprite.visible = false
	get_node('HookGuy').visible = false
	$ExplosionSFX.play()
	randomize()
	var scream = 1 + randi() % 9
	get_node(str('ScreamSFX', scream)).play()
	can_dive = false
	$DiveCooldown.visible = false
	emit_signal("died", self, is_player_collision)
	if hook != null:
		hook.rope.queue_free()
		hook.queue_free()
	emit_signal("shook_screen", SCREEN_SHAKE_EXPLOSION)
	$WaterParticles.visible = false
	set_physics_process(false)
	set_process_input(false)

func hook_collision(from_hook):
	$HookTimer.start()
	stunned = true
	pull_dir = (from_hook.rope.get_point_position(0)-from_hook.rope.get_point_position(1)).normalized()
	yield($HookTimer, "timeout")
	end_stun(from_hook)

func end_stun(hook):
	if weakref(hook).get_ref():
		hook.retract()
		hook.stop_at = null
	stunned = false

func _input(event):
	if input_type == 'Gamepad':
		if event.is_action_pressed('dive_'+str(id)) and can_dive:
			$DiveSFX.play()
			dive()
		elif event.is_action_pressed('shoot_'+str(id)) and !diving:
			if hook == null and not stunned:
				var hook_dir = get_arrow_direction()
				if hook_dir.length() < AXIS_DEADZONE:
					hook_dir = speed2
				emit_signal("hook_shot", self, hook_dir)
			elif hook and weakref(hook).get_ref() and not hook.retracting:
				hook.retract()
	elif input_type == "Keyboard_mouse":
		if event.is_action_pressed('dive_km') and can_dive:
			$DiveSFX.play()
			dive()
		elif event.is_action_pressed('shoot_km') and !diving:
			if hook == null and not stunned:
				var hook_dir = get_arrow_direction()
				if hook_dir.length() < AXIS_DEADZONE:
					hook_dir = speed2
				emit_signal("hook_shot", self, hook_dir)
			elif hook and weakref(hook).get_ref() and not hook.retracting:
				hook.retract()
		

func dive():
	$WaterParticles.visible = false
	var dive_particles = DIVE_PARTICLES.instance()
	dive_particles.emitting = true
	$ParticleTimer.wait_time = dive_particles.lifetime
	$ParticleTimer.start()
	self.add_child(dive_particles)
	can_dive = false
	diving = true
	sprite_animation.play("dive")
	$AnimationTimer.wait_time = sprite_animation.current_animation_length
	$AnimationTimer.start()
	$AnimationTimer.connect("timeout",self,"emerge")
	yield($ParticleTimer, 'timeout')
	dive_particles.queue_free()

func emerge():
	print("emerging")
	var dive_particles = DIVE_PARTICLES.instance()
	dive_particles.emitting = true
	$ParticleTimer.wait_time = dive_particles.lifetime
	$ParticleTimer.start()
	$WaterParticles.visible = true
	sprite_animation.play("walk")
	diving = false
	area.visible = true
	$DiveCooldown/CooldownTimer.wait_time = dive_cooldown
	$DiveCooldown/CooldownTimer.start()
	$EmergeSFX.play()

	# Cooldown progress bar
	bar.value = 100
	bar.visible = true
	tween.interpolate_property(bar, "value", 100, 0, dive_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield($ParticleTimer, 'timeout')
	dive_particles.queue_free()

func enable_diving():
	can_dive = true
	bar.visible = false
