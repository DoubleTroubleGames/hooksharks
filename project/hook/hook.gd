extends Node2D

var speed = 700
var acc = 500
var retracting = false
var kill_distance = 20

onready var bgm = get_node('/root/bgm')
var dir = Vector2()
var has_collided = false
var player = null
var rope = null
var stop_at = null

func shoot(direction):
	dir = direction

func _physics_process(delta):
	speed += acc * delta
	if stop_at != null:
		position = stop_at.position
	elif !has_collided:
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
	if object.is_in_group('hook') and not retracting:
		player.hook.retract()
		player.map.blink_screen()
		bgm.get_node('HookHitHook').play()
	elif object.is_in_group('player') and object != player and not retracting:
		if not object.stunned:
			stop_at = object
			object.hook_collision(self)
			bgm.get_node('HookHitPlayer').play()
	elif object.is_in_group('wall') and not retracting:
		has_collided = true
		bgm.get_node('HookHitWall').play()

func retract():
	retracting = true
