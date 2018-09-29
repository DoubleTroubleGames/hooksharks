extends Node2D

const ROT_SPEED = PI
const TRAIL = preload('res://player/trail.tscn')

onready var map = get_parent()
onready var sprite = get_node('Sprite')
onready var area = get_node('Area2D')

var speed = 200
var dir
var last_trail_pos = Vector2(0, 0)
var trail = TRAIL.instance()

func _ready():
	dir = Vector2(1, 0)

func _physics_process(delta):
	if Input.is_action_pressed('ui_right'):
		dir = dir.rotated(ROT_SPEED * delta)
	if Input.is_action_pressed('ui_left'):
		dir = dir.rotated(-ROT_SPEED * delta)
	
	self.position += dir * speed * delta
	sprite.rotation = dir.angle()
	area.rotation = dir.angle()
	if self.position.distance_to(last_trail_pos) > 2 * trail.get_node('Area2D/CollisionShape2D').get_shape().radius:
		create_trail(self.position)

func create_trail(pos):
	var trail = TRAIL.instance()
	trail.position = pos
	last_trail_pos = trail.position
	map.add_child(trail)
