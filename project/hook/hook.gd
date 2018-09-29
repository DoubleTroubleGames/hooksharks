extends Node2D

var speed = 700
var acc = 500
var retracting = false
var kill_distance = 20

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
	if retracting:
		dir = (player.position - self.position).normalized()
		position += dir * (delta * speed * 2)
		if position.distance_to(player.position) <= kill_distance:
			rope.queue_free()
			player.hook = null
			self.queue_free()

func _on_Area2D_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('hook'):
		player.hook.retract()
	elif object.is_in_group('player') and object != player:
		object.hook_collision(self)
	elif object.is_in_group('wall'):
		has_collided = true

func retract():
	retracting = true
