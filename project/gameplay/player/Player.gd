extends Node2D

signal created_trail(trail)
signal respawned(player)
signal died(player, is_player_collision)
signal hook_shot(player, direction)
signal watermine_released(player)
signal megahook_shot(player, direction)
signal shook_screen(amount)
signal spawned(id)
signal message_sent(text, color)
signal dive_value_changed(value)
signal dive_texture_changed(texture)
signal dive_visibility_changed(visibility)
signal dive_hide()
signal fire_trail_started(powerup)
signal infinite_dive_started(powerup)

onready var rider = $Shark/Rider
onready var riders_hook = $Shark/Rider/Hook
onready var sprite = $Shark
onready var sprite_animation = $Shark/AnimationPlayer
onready var area = $Shark/OverWaterArea
onready var rider_offset = -$Shark/Rider.position.x
onready var water_particles = $WaterParticles
onready var dont_collide = false
onready var original_hook_texture = $Shark/Rider/Hook.texture

enum MovementTypes {DIRECT, TANK}

const TRAIL = preload("res://assets/effects/trails/Trail.tscn")
const NORMAL_BUBBLE = preload("res://assets/images/ui/divebar-bubble.png")
const COOLDOWN_BUBBLE = preload("res://assets/images/ui/divebar-bubble-cd.png")
const BLOOD_PARTICLE = preload("res://assets/effects/BloodParticles.tscn")
const EXPLOSION_PARTICLE = preload("res://assets/effects/explosion/DeathExplosion.tscn")
const AXIS_DEADZONE = .5
const AXIS_DIRECTIONS := {"left": -1, "right": 1, "up": -1, "down": 1}
const SCREEN_SHAKE_EXPLOSION = 1
const DIRECT_MOVEMENT_MARGIN = PI / 36
const DIVE_USE_SPEED = 75
const DIVE_REGAIN_SPEED = 40
const DIVE_COOLDOWN_SPEED = 40
const WALL_PULL_FORCE_MUL = 2
const PULL_PLAYER_FACTOR = 3.5
const ORIGINAL_HOOK_SCALE = Vector2(.6,.6)
const SHARKS = {
	"drill": preload("res://characters/drill/Shark.tscn"),
	"jackie": preload("res://characters/jackie/Shark.tscn"),
	"king": preload("res://characters/king/Shark.tscn"),
	"outsider": preload("res://characters/outsider/Shark.tscn"),
}

export(Vector2) var initial_dir = Vector2(1, 0)
export(bool) var create_trail = true
export(bool) var respawn = false
export(float) var ROT_SPEED = PI/3.5
export(int) var ACC = 8
export(int) var INITIAL_SPEED = 100
export(int) var MAX_SPEED = -1 # -1 lets speed grow without limit
export(MovementTypes) var movement_type = MovementTypes.DIRECT

var id = 0
var gamepad_id = -1
var device_name = ""
var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()
var dive_value = 100
var diving = false
var can_dive = true
var dive_on_cooldown = false
var infinite_dive = false
var whirlpool = null
var invincible = false
var stunned = false
var is_respawning = false
var hook = null
var pull_dir = null
var speed2 = Vector2(INITIAL_SPEED, 0)
var is_pressed = {"dive": false, "shoot": false, "left": false, "right": false,
		"up": false, "down": false, "pause": false}
var disabled = false

func _ready():
	if device_name.begins_with("gamepad"):
		gamepad_id = device_name.split("_")[1].to_int()
	
	speed2 = speed2.rotated(initial_dir.angle())
	
	emit_signal("dive_value_changed", 100)
	emit_signal("dive_texture_changed", NORMAL_BUBBLE)
	
	set_physics_process(false)
	set_process_input(false)

func spawn_animation():
	yield(get_tree().create_timer(rand_range(.3,1.3)), "timeout")
	sprite_animation.play("spawn")
	emit_signal("spawned", id)
	yield(sprite_animation, "animation_finished")
	sprite_animation.play("emerge")
	yield(sprite_animation, "animation_finished")
	sprite_animation.play("idle")


func _input(event):
	if RoundManager.get_device_name_from(event) != device_name:
		return

	update_input_map()
	apply_action_presses(event)


func _physics_process(delta):
	# Update dive meter
	update_dive_meter(delta)
	
	#Update "invincible animation"
	if invincible:
		$Shark.modulate.a = 0.5 if Engine.get_frames_drawn() % 16 <= 7 else 1.0
	
	speed2 += speed2.normalized() * ACC * delta

	var applying_force = Vector2(0, 0)
	var turning_left = false
	var turning_right = false
	
	if hook != null and weakref(hook).get_ref() and hook.is_colliding()\
			and not hook.is_pulling_object():
		applying_force = hook.rope.get_applying_force()
	elif not stunned:
		if movement_type == MovementTypes.TANK:
			turning_right = is_pressed["right"]
			turning_left = is_pressed["left"]
		elif movement_type == MovementTypes.DIRECT:
			var direction = get_movement_direction()
			
			if direction.length() > 0:
				turning_right = speed2.angle_to(direction) > DIRECT_MOVEMENT_MARGIN
				turning_left = speed2.angle_to(direction) < -DIRECT_MOVEMENT_MARGIN
		else:
			print("Not a valid movement type: ", movement_type)
			assert(false)
	
	if turning_left == turning_right:
		pass
	elif turning_left:
		speed2 = speed2.rotated(-ROT_SPEED * delta)
	else: # turning_right:
		speed2 = speed2.rotated(ROT_SPEED * delta)
	
	var anim = sprite_animation.current_animation
	
	if anim != "dive" and anim != "emerge":
		var new_anim = "dive_" if diving else ""
		if turning_left == turning_right:
			new_anim += "idle"
		elif turning_left:
			new_anim += "left"
		else: #turning_right
			new_anim += "right"
		
		if anim != new_anim:
			sprite_animation.play(new_anim)
	
	var proj = (applying_force.dot(speed2) / speed2.length_squared()) * speed2
	applying_force -= proj
	
	if stunned:
		var pull_rotation = speed2.angle_to(pull_dir)
		speed2 = speed2.rotated(pull_rotation * delta * PULL_PLAYER_FACTOR)
		applying_force = pull_dir
	if MAX_SPEED != -1:
		speed2 = speed2.clamped(MAX_SPEED)
		
	#Apply whirlpool force
	if whirlpool:
		speed2 += whirlpool.get_applying_force(self) 
	
	position += speed2 * delta
	speed2 += applying_force.normalized() * speed2.length() * WALL_PULL_FORCE_MUL * delta
	
	sprite.rotation = speed2.angle()
	
	water_particles.ripples.speed_scale = max(0.5, int(speed2.length() / 200))
	
	if self.create_trail and not diving and\
			self.position.distance_to(last_trail_pos) >\
			2 * trail.get_node('Area2D/CollisionShape2D').get_shape().radius:
		create_trail(self.position)
	
	# Update rider direction
	rider.look_at(rider.global_position + get_rider_direction())
	
	if diving and not is_pressed["dive"]:
		emerge()
		retract()


func disable():
	disabled = true
	dont_collide = true
	water_particles.ripples.emitting = false
	set_physics_process(false)
#	set_process_input(false)


func enable():
	disabled = false
	dont_collide = false
	$WaterParticles.show()
	water_particles.ripples.emitting = true
	set_physics_process(true)
	set_process_input(true)


func add_shark(shark_name):
	var old = $Shark
	var new = SHARKS[shark_name].instance()
	
	old.set_name("old shark")
	old.queue_free()
	new.set_name("Shark")
	new.rotation = initial_dir.angle()
	
	area = new.get_node("UnderWaterArea")
	area.connect("area_entered", self, "_on_UnderWater_area_entered")
	area = new.get_node("OverWaterArea") # OverWater must be set to area last
	area.connect("area_entered", self, "_on_OverWater_area_entered")
	area.connect("area_exited", self, "_on_OverWater_area_exited")
	
	add_child(new)


func add_label(text, color = Color.white):
	emit_signal("message_sent", text, color)


func start_infinite_dive():
	infinite_dive = true
	dive_on_cooldown = false
	dive_value = 100
	emit_signal("dive_value_changed", dive_value)
	emit_signal("dive_texture_changed", NORMAL_BUBBLE)


func update_dive_meter(delta):
	if infinite_dive:
		
		return
	elif dive_on_cooldown:
		dive_value += DIVE_COOLDOWN_SPEED * delta
		if dive_value >= 100:
			reset_dive_meter(false)
	elif diving:
		dive_value -= DIVE_USE_SPEED * delta
		if dive_value <= 0:
			dive_value = 0
			emit_signal("dive_texture_changed", COOLDOWN_BUBBLE)
			dive_on_cooldown = true
			emerge()
	else:
		dive_value += DIVE_USE_SPEED * delta
		if dive_value >= 100:
			dive_value = 100
	
	emit_signal("dive_value_changed", dive_value)
	
	if dive_value < 100:
		emit_signal("dive_visibility_changed", true)
	else:
		emit_signal("dive_visibility_changed", false)


func reset_dive_meter(hard_change):
	dive_value = 100
	dive_on_cooldown = false
	
	emit_signal("dive_value_changed", dive_value)
	emit_signal("dive_texture_changed", NORMAL_BUBBLE)
	if hard_change:
		emit_signal("dive_hide")


func get_rider_direction():
	if gamepad_id != -1:
		var direction = Vector2(
				Input.get_joy_axis(gamepad_id, JOY_ANALOG_RX),
				Input.get_joy_axis(gamepad_id, JOY_ANALOG_RY)
			)
		if direction.length() > AXIS_DEADZONE:
			return direction.normalized()

		return speed2.normalized()
	
	return (get_global_mouse_position() - get_position()).normalized()


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


func die(play_sfx):
	var EP = EXPLOSION_PARTICLE.instance()
	
	EP.position = self.position
	get_parent().add_child(EP)
	sprite_animation.stop(false)
	reset_dive_meter(false)
	emit_signal("dive_visibility_changed", false)
	emit_signal("shook_screen", SCREEN_SHAKE_EXPLOSION)
	if play_sfx and $Shark/ExplosionSFXs.get_child_count() > 0:
		var sfx_number = randi() % $Shark/ExplosionSFXs.get_child_count()
		$Shark/ExplosionSFXs.get_child(sfx_number).play()
	if play_sfx and $Shark/DeathSFXs.get_child_count() > 0:
		var sfx_number = randi() % $Shark/DeathSFXs.get_child_count()
		$Shark/DeathSFXs.get_child(sfx_number).play()
	disable()
	
	if respawn:
		#Remove all powerups from player
		for i in range(0, $PowerUps.get_child_count()):
			var power = $PowerUps.get_child(i)
			power.deactivate()
		sprite.set_modulate(Color(1, 1, 1, 0.2))
		riders_hook.texture = original_hook_texture
		riders_hook.scale = ORIGINAL_HOOK_SCALE
		riders_hook.offset = Vector2()
		if hook:
			hook.retract()
			hook.free_hook()
		emit_signal("respawned", self)
	else:
		if hook != null:
			hook.retract()
			hook.free_hook()
		emit_signal("died", self)
		sprite_animation.play("dive")
		var Twn = Tween.new()
		add_child(Twn)
		Twn.interpolate_property(sprite, "modulate:a", null, 0, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN)
		Twn.start()


func hook_collision(from_hook):
	var BP = BLOOD_PARTICLE.instance()
	BP.position = self.position
	get_parent().add_child(BP)
	$HookTimer.start()
	
	#Play a random hit sfx
	var sfx_number = randi() % $Shark/HitSFXs.get_child_count()
	$Shark/HitSFXs.get_child(sfx_number).play()
	
	stunned = true
	pull_dir = (from_hook.player.position - \
			from_hook.position).normalized()
	
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
	can_dive = false
	sprite_animation.play("dive")
	yield(get_tree().create_timer(0.2), "timeout")
	if sprite_animation.assigned_animation.begins_with("dive"):
		# Verification in case diving was canceled
		diving = true
		sprite_animation.play("dive_idle")


func emerge():
	if not diving:
		return
	
	$SFX/EmergeSFX.play()
	sprite_animation.play("emerge")
	diving = false
	yield(sprite_animation, "animation_finished")
	for a in area.get_overlapping_areas():
		if a.collision_layer == Collision.FLOATING_OBSTACLE:
			die(true)
	can_dive = true
	sprite_animation.play("idle")


func shoot():
	if diving:
		return
	
	if hook == null and not stunned:
		var hook_dir = get_rider_direction()
		if hook_dir.length() < AXIS_DEADZONE:
			hook_dir = speed2
		if not $PowerUps.has_node("MegaHook") and not $PowerUps.has_node("WaterMine"):
			emit_signal("hook_shot", self, hook_dir) # recieved in Game.gd
			riders_hook.hide()
		elif $PowerUps.has_node("WaterMine"):
			emit_signal("watermine_released", self) # recieved in Game.gd
		elif $PowerUps.has_node("MegaHook"):
			emit_signal("megahook_shot", self, hook_dir) # recieved in Game.gd
			riders_hook.texture = original_hook_texture
			riders_hook.scale = ORIGINAL_HOOK_SCALE
			riders_hook.offset = Vector2()
		

func retract():
	if diving:
		return
	if hook and weakref(hook).get_ref() and not hook.retracting:
		hook.retract()


func hook_retracted():
	hook = null
	riders_hook.show()


# Handles applying all actions that aren't movement-related.
#
# By default, the current action presses will be applied even if the player has
# not done anything new. This is useful for ensuring that a player's held inputs
# are still applied when unpausing the game.
#
# If an InputEvent is provided, the player's input will only be applied if it
# was changed in that event. This is useful when an action should only be done
# once when pressed or released.
func apply_action_presses(event: InputEvent = null) -> void:
	if event:
		if event.is_action_pressed("pause"):
			# Passing self as source_node is useful for scripts
			# that want to know what node paused the game (see PauseScreen).
			PauseManager.set_pause(true, {"source_node": self})

		if disabled:  # Only pausing is allowed when disabled.
			return

		if event.is_action_pressed("dive"):
			dive()

		elif event.is_action_released("dive"):
			emerge()

		if event.is_action_pressed("shoot"):
			shoot()

		elif event.is_action_released("shoot"):
			retract()

		return

	# If no event was provided:
	if is_pressed["pause"]:
		PauseManager.set_pause(true, {"source_node": self})

	if disabled:  # Only pausing is allowed when disabled.
		return

	if is_pressed["dive"]:
		dive()

	else:
		emerge()

	if is_pressed["shoot"]:
		shoot()

	else:
		retract()


# Updates whether each action in is_pressed is currently pressed. Does not take
# into account whether that action was recently pressed or released.
func update_input_map() -> void:
	for action_name in is_pressed:
		var action_pressed := false

		for action_input in ProjectSettings.get_setting("input/%s" % action_name)["events"]:
			var action_input_pressed := false

			if action_input is InputEventJoypadMotion:
				var axis_direction: int = AXIS_DIRECTIONS.get(action_name, 0)
				var axis_input := Input.get_joy_axis(gamepad_id, action_input.get_axis())

				# axis_input must have a magnitude greater than AXIS_DEADZONE and have
				# the same sign as axis_direction for action_input_pressed to be true.
				action_input_pressed = (
						abs(axis_input) > AXIS_DEADZONE
						and (
								axis_input > 0 and axis_direction > 0
								or axis_input < 0 and axis_direction < 0
						)
				)

			elif action_input is InputEventJoypadButton:
				action_input_pressed = Input.is_joy_button_pressed(
						gamepad_id,
						action_input.get_button_index()
				)

			elif gamepad_id == -1:  # -1 means this player does not have a gamepad assigned.
				if action_input is InputEventKey:
					action_input_pressed = Input.is_key_pressed(
							action_input.get_scancode()
					)

				elif action_input is InputEventMouseButton:
					action_input_pressed = Input.is_mouse_button_pressed(
							action_input.get_button_index()
					)

			# Using "or" means that if any action_input for action_name
			# is pressed, then action_pressed will stay true.
			action_pressed = action_pressed or action_input_pressed

		is_pressed[action_name] = action_pressed


func reset_input_map():
	for action_name in is_pressed:
		is_pressed[action_name] = false


func reset_input() -> void:
	reset_input_map()
	apply_action_presses()


func start_invincibility():
	invincible = true
	$InvincibilityTimer.start()
	yield($InvincibilityTimer, "timeout")
	invincible = false
	$Shark.modulate.a = 1.0


func _on_OverWater_area_exited(area):
	match area.collision_layer:
		Collision.TRAIL:
			var trail = area.get_parent()
			trail.can_collide = true
		Collision.WHIRLPOOL:
			whirlpool = null


func _on_OverWater_area_entered(area):
	if not dont_collide:
		match area.collision_layer:
			Collision.PLAYER_ABOVE:
				var other_player = area.get_parent().get_parent()
				if diving == other_player.diving and not invincible and not other_player.dont_collide:
					die(true)
					other_player.die(true)
			Collision.OBSTACLE:
				die(true)
			Collision.FLOATING_OBSTACLE:
				if not diving:
					die(true)
			Collision.TRAIL:
				var trail = area.get_parent()
				if not diving and trail.can_collide and not invincible:
					die(true)
			Collision.POWERUP:
				if not diving:
					var powerup = area.get_parent()
					powerup.add_powerup(self)
			Collision.WHIRLPOOL:
				whirlpool = area.get_parent()
			Collision.DEATHZONE:
				die(true)


func _on_UnderWater_area_entered(area):
	if not dont_collide:
		match area.collision_layer:
			Collision.PLAYER_BELOW:
				var other_player = area.get_parent().get_parent()
				if diving == other_player.diving and not invincible and not other_player.dont_collide:
					die(true)
					other_player.die(true)
			Collision.UNDERWATER_OBSTACLE:
				if diving:
					die(true)
			Collision.WHIRLPOOL:
				whirlpool = area.get_parent()
			Collision.DEATHZONE:
				die(true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dive":
		sprite_animation.play("dive_idle")
