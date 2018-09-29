extends Node2D

const ROT_SPEED = PI/2.5
const TRAIL = preload('res://player/trail.tscn')
const ACC = 5
const INITIAL_SPEED = 100
const AXIS_DEADZONE = .1

onready var arrow = $Arrow
onready var map = get_node('../../')
onready var sprite = get_node('Sprite')
onready var area = get_node('Area2D')
onready var round_manager = map.get_node('RoundManager')

var dir
var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()
var diving = false 
var can_dive = true
var dive_cooldown = 3
var dive_duration = 1
var stunned = false
var hook = null
var joy_id = 0
var score = 0
var id

var speed2 = Vector2(INITIAL_SPEED, 0)

func _ready():
	id = int(self.name[6])
	dir = Vector2(1, 0)

func _physics_process(delta):
	speed2 += speed2.normalized() * ACC * delta
	var applying_force = Vector2(0, 0)
	
	if hook != null and hook.has_collided:
		applying_force = hook.rope.get_applying_force()
	else:
		if (Input.is_action_pressed('ui_right') or Input.get_joy_axis(joy_id, 0) > AXIS_DEADZONE) and not stunned:
			speed2 = speed2.rotated(ROT_SPEED * delta)
		if (Input.is_action_pressed('ui_left') or Input.get_joy_axis(joy_id, 0) < -AXIS_DEADZONE) and not stunned:
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
	var arrow_dir = Vector2(Input.get_joy_axis(joy_id, 2), Input.get_joy_axis(joy_id, 3))
	arrow.visible = (arrow_dir.length() > AXIS_DEADZONE)	
	arrow.rotation = arrow_dir.angle()
	

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

func _queue_free():
	$Scream.play()
	round_manager.remove_player(self)
	if hook != null:
		hook.rope.queue_free()
		hook.queue_free()
	self.queue_free()

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
#	print(event.as_text())
	if event.is_action_pressed('dive') and can_dive:
		dive()
	elif event.is_action_pressed('shoot') and !diving:
		if hook == null:
			var hook_dir = Vector2(Input.get_joy_axis(joy_id, 2), Input.get_joy_axis(joy_id, 3))
			if hook_dir.length() < AXIS_DEADZONE:
				hook_dir = speed2
			hook = map.create_hook(self, Vector2(Input.get_joy_axis(joy_id, 2), Input.get_joy_axis(joy_id, 3)))
	elif event.is_action_pressed('cancel') and hook and hook.has_collided:
		hook.rope.queue_free()
		hook.queue_free()
		hook = null

func dive():
	var timer = Timer.new()
	can_dive = false
	diving = true
	timer.wait_time = dive_duration
	area.visible = false
	timer.connect('timeout', self, 'emerge')
	timer.start()
	self.add_child(timer)

func emerge():
	var timer = Timer.new()
	diving = false
	timer.wait_time = dive_cooldown
	area.visible = true
	timer.connect('timeout', self, 'enable_diving')
	timer.start()
	self.add_child(timer)

func enable_diving():
	can_dive = true
