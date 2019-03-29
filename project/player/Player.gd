extends Node2D

signal created_trail(trail)
signal died(player, is_player_collision)
signal hook_shot(player, direction)
signal megahook_shot(player, direction)
signal shook_screen(amount)

onready var rider = $Sprite/Rider
onready var dive_meter = $DiveCooldown/Bar
onready var dive_bar = $DiveCooldown
onready var sprite = $Sprite
onready var sprite_animation = $Sprite/AnimationPlayer
onready var area = $Area2D
onready var rider_offset = -$Sprite/Rider.position.x
onready var water_particles = $WaterParticles

enum MovementTypes {DIRECT, TANK}

const TRAIL = preload("res://fx/trails/Trail.tscn")
const DIVE_PARTICLES = preload("res://fx/DiveParticles.tscn")
const NORMAL_BUBBLE = preload("res://fx/bubble.png")
const COOLDOWN_BUBBLE = preload("res://fx/cd_bubble.png")
const BLOOD_PARTICLE = preload("res://fx/BloodParticles.tscn")
const EXPLOSION_PARTICLE = preload("res://fx/explosion/DeathExplosion.tscn")
const AXIS_DEADZONE = .5
const SCREEN_SHAKE_EXPLOSION = 1
const DIRECT_MOVEMENT_MARGIN = PI / 36
const DIVE_USE_SPEED = 75
const DIVE_REGAIN_SPEED = 40
const DIVE_COOLDOWN_SPEED = 40
const PULL_FORCE = 300
const DISPLACEMENT_FACTOR = .7

export(Vector2) var initial_dir = Vector2(1, 0)
export(bool) var create_trail = true
export(float) var ROT_SPEED = PI/3.5
export(int) var ACC = 4
export(int) var INITIAL_SPEED = 100
export(int) var MAX_SPEED = -1 # -1 lets speed grow without limit
export(MovementTypes) var movement_type = MovementTypes.TANK

var id = 0
var gamepad_id = -1
var device_name = ""
var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()
var diving = false
var can_dive = true
var dive_on_cooldown = false
var stunned = false
var hook = null
var pull_dir = null
var speed2 = Vector2(INITIAL_SPEED, 0)
var is_pressed = {"dive": false, "shoot": false, "left": false, "right": false,
		"up": false, "down": false, "pause": false}

func _ready():
	if device_name.begins_with("gamepad"):
		gamepad_id = device_name.split("_")[1].to_int()
	
	randomize()
	speed2 = speed2.rotated(initial_dir.angle())
	dive_meter.texture_progress = NORMAL_BUBBLE
	dive_meter.value = 100
	set_physics_process(false)
	set_process_input(false)


func _input(event):
	if RoundManager.get_device_name_from(event) != device_name:
		return
	
	for action in is_pressed.keys():
		if event.is_action(action):
			is_pressed[action] = event.is_pressed() or\
					(event is InputEventKey and event.is_echo())
			break
	
	if event.is_action_pressed("dive"):
		dive()
	elif event.is_action_released("dive"):
		emerge()
	elif event.is_action_pressed("shoot"):
		shoot()


func _physics_process(delta):
	# Update dive meter
	if dive_on_cooldown:
		dive_meter.value += DIVE_COOLDOWN_SPEED * delta
		if dive_meter.value >= 100:
			dive_meter.value = 100
			dive_on_cooldown = false
			dive_meter.texture_progress = NORMAL_BUBBLE
	elif diving:
		dive_meter.value -= DIVE_USE_SPEED * delta
		if dive_meter.value <= 0:
			dive_meter.value = 0
			dive_meter.texture_progress = COOLDOWN_BUBBLE
			dive_on_cooldown = true 
			emerge()
	else:
		dive_meter.value += DIVE_USE_SPEED * delta
		if dive_meter.value >= 100:
			dive_meter.value = 100
	if dive_meter.value < 100:
		dive_bar.visible = true
	else:
		dive_bar.visible = false
	
	speed2 += speed2.normalized() * ACC * delta
	var applying_force = Vector2(0, 0)

	if hook != null and weakref(hook).get_ref() and hook.is_colliding()\
			and not hook.is_pulling_object():
		applying_force = hook.rope.get_applying_force()
	elif not stunned:
		if movement_type == MovementTypes.TANK:
			
			# Workaround for gamepad bug
			if device_name.begins_with("gamepad"):
				var direction = get_movement_direction()
				is_pressed["right"] = direction.x > AXIS_DEADZONE
				is_pressed["left"] = direction.x < - AXIS_DEADZONE
			else:
				if is_pressed["right"]:
					speed2 = speed2.rotated(ROT_SPEED * delta)
				if is_pressed["left"]:
					speed2 = speed2.rotated(-ROT_SPEED * delta)
		elif movement_type == MovementTypes.DIRECT:
			var direction = get_movement_direction()
			
			if direction.length() > 0:
				if speed2.angle_to(direction) > DIRECT_MOVEMENT_MARGIN:
					speed2 = speed2.rotated(ROT_SPEED * delta)
				elif speed2.angle_to(direction) < -DIRECT_MOVEMENT_MARGIN:
					speed2 = speed2.rotated(-ROT_SPEED * delta)
		else:
			print("Not a valid movement type: ", movement_type)
			assert(false)
	
	var proj = (applying_force.dot(speed2) / speed2.length_squared()) * speed2
	applying_force -= proj
	
	if stunned:
		position += pull_dir * PULL_FORCE * delta * DISPLACEMENT_FACTOR
		applying_force = pull_dir * PULL_FORCE
	if MAX_SPEED != -1:
		speed2 = speed2.clamped(MAX_SPEED)
	
	position += speed2 * delta
	speed2 += applying_force * delta
	
	rotation = speed2.angle()
	
	if self.create_trail and not diving and\
			self.position.distance_to(last_trail_pos) >\
			2 * trail.get_node('Area2D/CollisionShape2D').get_shape().radius:
		create_trail(self.position)
	
	# Update rider direction
	var rider_dir = get_rider_direction()
	rider_dir.x *= -1
	rider.global_rotation = rider_dir.angle()
	
	dive_bar.global_rotation = 0
	
	if diving and not is_pressed["dive"]:
		emerge()


func disable():
	area.set_deferred("monitoring", false)
	area.set_deferred("monitorable", false)
	water_particles.ripples.emitting = false
	set_physics_process(false)
	set_process_input(false)


func enable():
	water_particles.ripples.emitting = true
	set_physics_process(true)
	set_process_input(true)


func get_rider_direction():
	if gamepad_id != -1:
		var direction = Vector2(Input.get_joy_axis(gamepad_id, JOY_ANALOG_RX),
				Input.get_joy_axis(gamepad_id, JOY_ANALOG_RY))
		if direction.length() > AXIS_DEADZONE:
			return direction
		return speed2.normalized()
	
	return get_global_mouse_position() - get_position()


func get_movement_direction():
	var direction = Vector2()
	
	if gamepad_id != -1:
		direction = Vector2(Input.get_joy_axis(gamepad_id, JOY_ANALOG_LX),
				Input.get_joy_axis(gamepad_id, JOY_ANALOG_LY))
		if direction.length() > AXIS_DEADZONE:
			return direction
		return Vector2()
	
	if is_pressed["right"]:
		direction += Vector2(1, 0)
	if is_pressed["left"]:
		direction += Vector2(-1, 0)
	if is_pressed["up"]:
		direction += Vector2(0, -1)
	if is_pressed["down"]:
		direction += Vector2(0, 1)
	
	return direction.normalized()


func create_trail(pos):
	var trail = TRAIL.instance()
	trail.position = pos
	trail.rotation = speed2.angle()
	last_trail_pos = trail.position
	emit_signal("created_trail", trail)


func die(is_player_collision=false):
	var EP = EXPLOSION_PARTICLE.instance()
	EP.position = self.position
	EP.z_index = 2
	$Area2D.queue_free()
	sprite_animation.stop(false)
	sprite.hide()
	rider.hide()
	$DiveCooldown.hide()
	$SFX/ExplosionSFX.play()
	for particle in EP.get_children():
		particle.emitting = true
	get_parent().add_child(EP)
	randomize()
	var scream = 1 + randi() % 9
	get_node(str('SFX/ScreamSFX', scream)).play()
	emit_signal("died", self, is_player_collision)
	if hook != null:
		hook.free_hook()
	rider.hide()
	emit_signal("shook_screen", SCREEN_SHAKE_EXPLOSION)
	disable()


func hook_collision(from_hook):
	var BP = BLOOD_PARTICLE.instance()
	BP.position = self.position
	$HookTimer.start()
	$SFX/OnHit.play()
	get_parent().add_child(BP)
	stunned = true
	pull_dir = (from_hook.rope.get_point_position(0) - \
			from_hook.rope.get_point_position(1)).normalized()
	
	if not can_dive: # player was diving or emerging when hooked
		if sprite_animation.current_animation != "emerge":
			emerge()
	
	yield($HookTimer, "timeout")
	end_stun(from_hook)


func end_stun(hook):
	if weakref(hook).get_ref():
		hook.retract()
		hook.stop_at = null
	stunned = false


func dive():
	if not can_dive or diving or dive_on_cooldown:
		return
	
	$SFX/DiveSFX.play()
	$WaterParticles.visible = false
	var dive_particles = DIVE_PARTICLES.instance()
	dive_particles.emitting = true
	$ParticleTimer.wait_time = dive_particles.lifetime
	$ParticleTimer.start()
	self.add_child(dive_particles)
	can_dive = false
	sprite_animation.play("dive")
	yield(sprite_animation, "animation_finished")
	if sprite_animation.assigned_animation == "dive":
		# Verification in case diving was canceled
		diving = true
	yield($ParticleTimer, 'timeout')
	dive_particles.queue_free()


func emerge():
	if not diving:
		return
	
	$SFX/EmergeSFX.play()
	var dive_particles = DIVE_PARTICLES.instance()
	dive_particles.emitting = true
	$ParticleTimer.wait_time = dive_particles.lifetime
	$ParticleTimer.start()
	$WaterParticles.visible = true
	sprite_animation.play("emerge")
	diving = false
	yield(sprite_animation, "animation_finished")
	for area in $Area2D.get_overlapping_areas():
		if area.get_parent().is_in_group('wall'):
			die()
	can_dive = true
	sprite_animation.play("idle")
	yield($ParticleTimer, 'timeout')
	dive_particles.queue_free()


func shoot():
	if diving:
		return
	
	if hook == null and not stunned:
		var hook_dir = get_rider_direction()
		if hook_dir.length() < AXIS_DEADZONE:
			hook_dir = speed2
		if not $PowerUps.has_node("MegaHook"):
			emit_signal("hook_shot", self, hook_dir)
			$Sprite/Rider/Hook.hide()
		else:
			$PowerUps/MegaHook.queue_free()
			emit_signal("megahook_shot", self, hook_dir)
	elif hook and weakref(hook).get_ref() and not hook.retracting:
		hook.retract()


func hook_retracted():
	hook = null
	$Sprite/Rider/Hook.show()


func _on_Area2D_area_exited(area):
	var object = area.get_parent()
	if object.is_in_group('trail'):
		object.can_collide = true


func _on_Area2D_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('trail') and object.can_collide and not diving:
		die()
	if object.is_in_group('wall'):
		if diving and area.is_in_group('underpass'):
			pass
		else:
			die()
	if object.is_in_group('player') and object != self:
		if diving == object.diving:
			die(true)
	if object.is_in_group('powerup') and not diving:
		object.activate(self)
