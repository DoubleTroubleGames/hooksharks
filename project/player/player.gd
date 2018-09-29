extends Node2D

const ROT_SPEED = PI
const TRAIL = preload('res://player/trail.tscn')

onready var map = get_parent()
onready var sprite = get_node('Sprite')
onready var area = get_node('Area2D')

var speed = 100
var dir
var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()
var diving = false
var can_dive = true
var dive_cooldown = 3
var dive_duration = 1
var stunned = false
var hook = null

func _ready():
	dir = Vector2(1, 0)

func _physics_process(delta):
	if Input.is_action_pressed('ui_right') and not stunned:
		dir = dir.rotated(ROT_SPEED * delta)
	if Input.is_action_pressed('ui_left') and not stunned:
		dir = dir.rotated(-ROT_SPEED * delta)
	
	self.position += dir * speed * delta
	sprite.rotation = dir.angle()
	area.rotation = dir.angle()
	if self.position.distance_to(last_trail_pos) > 2 * trail.get_node('Area2D/CollisionShape2D').get_shape().radius:
		if not diving:
			create_trail(self.position)

func create_trail(pos):
	var trail = TRAIL.instance()
	trail.position = pos
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
	if event.is_action_pressed('ui_accept') and can_dive:
		dive()
	if event.is_action_pressed('shoot') and !diving:
		if hook == null:
			hook = map.create_hook(self)
		elif hook.has_collided:
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
