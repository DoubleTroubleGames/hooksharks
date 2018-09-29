extends Node2D

var speed = 700
var acc = 500

var dir = Vector2()
var has_collided = false
var player = null
var rope = null

func shoot(direction):
	dir = direction

func _physics_process(delta):
	speed += acc * delta
	if !has_collided:
		position += dir * (delta * speed)

func _on_Area2D_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('hook'):
		object.queue_free()
		queue_free()
	elif object.is_in_group('player') and object != player:
		object.hook_collision()
	elif object.is_in_group('wall'):
		has_collided = true
