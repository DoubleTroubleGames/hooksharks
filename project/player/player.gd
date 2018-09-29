extends Node2D

const ROT_SPEED = PI/3.5
const TRAIL = preload('res://player/trail.tscn')
const ACC = 4
const INITIAL_SPEED = 100
const AXIS_DEADZONE = .2

export (int)var id

onready var arrow = $Arrow
onready var bar = $DiveCooldown/Bar
onready var dive_bar = $DiveCooldown
onready var map = get_node('../../')
onready var sprite = get_node('Sprite')
onready var area = get_node('Area2D')
onready var round_manager = map.get_node('RoundManager')
onready var tween = $Tween

var dir
var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()
var diving = false 
var can_dive = true
var dive_cooldown = 3
var dive_duration = 1
var stunned = false
var hook = null
var score = 0

var speed2 = Vector2(INITIAL_SPEED, 0)

func _ready():
	dir = Vector2(1, 0)

func _physics_process(delta):
	speed2 += speed2.normalized() * ACC * delta
	var applying_force = Vector2(0, 0)
	
	if hook != null and hook.has_collided:
		applying_force = hook.rope.get_applying_force()
	else:
		if Input.get_joy_axis(id, 0) > AXIS_DEADZONE and not stunned:
			speed2 = speed2.rotated(ROT_SPEED * delta)
		if Input.get_joy_axis(id, 0) < -AXIS_DEADZONE and not stunned:
			speed2 = speed2.rotated(-ROT_SPEED * delta)
	
	var proj = (applying_force.dot(speed2) / speed2.length_squared()) * speed2
	applying_force -= proj
	
	speed2 += applying_force * delta
	position += speed2 * delta

	rotation = speed2.angle()
	
	if self.position.distance_to(last_trail_pos) > 2 * trail.get_node('Area2D/CollisionShape2D').get_shape().radius:
		if not diving:
			create_trail(self.position)
	
	# Arrow direction
	var arrow_dir = Vector2(Input.get_joy_axis(id, 2), Input.get_joy_axis(id, 3))
	arrow.visible = (arrow_dir.length() > AXIS_DEADZONE and !diving)
	arrow.global_rotation = arrow_dir.angle()
	
	dive_bar.global_rotation = 0

func create_trail(pos):
	var trail = TRAIL.instance()
	trail.position = pos
	trail.rotation = speed2.angle()
	last_trail_pos = trail.position
	map.add_child(trail)

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
		_queue_free(true)

func _queue_free(player_collision=false):
	$Scream.play()
	can_dive = false
	$DiveCooldown.visible = false
	round_manager.remove_player(self, player_collision)
	if hook != null:
		hook.rope.queue_free()
		hook.queue_free()
	set_physics_process(false)

func hook_collision():
	var timer = Timer.new()
	timer.wait_time = 2
	timer.start()
	self.add_child(timer)
	timer.connect('timeout', self, 'end_stun')
	stunned = true

func end_stun():
	stunned = false

func _input(event):
	if event.is_action_pressed('dive_'+str(id)) and can_dive:
		dive()
	elif event.is_action_pressed('shoot_'+str(id)) and !diving:
		if hook == null and not stunned:
			var hook_dir = Vector2(Input.get_joy_axis(id, 2), Input.get_joy_axis(id, 3))
			if hook_dir.length() < AXIS_DEADZONE:
				hook_dir = speed2
			hook = map.create_hook(self, hook_dir)
			hook.get_node("Sprite").rotation = hook_dir.angle()
		elif !diving:
			hook.retract()
			var hook_dir = Vector2(Input.get_joy_axis(id, 2), Input.get_joy_axis(id, 3))
			if hook_dir.length() < AXIS_DEADZONE:
				hook_dir = speed2
			hook = map.create_hook(self, hook_dir)
			hook.get_node("Sprite").rotation = hook_dir.angle()
	elif event.is_action_pressed('cancel_'+str(id)) and hook and hook.has_collided:
		hook.retract()
		hook = null

func dive():
	can_dive = false
	diving = true
	$Sprite/AnimationPlayer.play("dive")
	var timer = Timer.new()
	timer.wait_time = $Sprite/AnimationPlayer.current_animation_length
	timer.start()
	self.add_child(timer)
	timer.connect("timeout",self,"emerge",[timer])

func emerge(_timer):
	_timer.queue_free()
	$Sprite/AnimationPlayer.play("walk")
	var timer = Timer.new()
	diving = false
	timer.wait_time = dive_cooldown
	area.visible = true
	timer.connect('timeout', self, 'enable_diving', [timer])
	timer.start()
	self.add_child(timer)
	
	# Cooldown progress bar
	bar.value = 100
	bar.visible = true
	tween.interpolate_property(bar, "value", 100, 0, dive_cooldown, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func enable_diving(timer):
	timer.queue_free()
	can_dive = true
	bar.visible = false
