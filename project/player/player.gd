extends Node2D

const ROT_SPEED = PI/2

var speed = 100
var dir

func _ready():
	dir = Vector2(1, 0)

func _physics_process(delta):
	self.position += dir * speed * delta
	if Input.is_action_pressed('ui_right'):
		dir = dir.rotated(ROT_SPEED * delta)
	if Input.is_action_pressed('ui_left'):
		dir = dir.rotated(-ROT_SPEED * delta)
