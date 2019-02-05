extends Node2D

signal shook_screen(amount)

onready var hook_clink = get_node('../../HookClink')

const SCREEN_SHAKE_HOOK_HIT = .8
const SCREEN_SHAKE_OBJECT_HIT = .1
const SCREEN_SHAKE_SHARK_HIT = .7
const SCREEN_SHAKE_WALL_HIT = .3

var speed = 700
var acc = 500
var retracting = false
var pulling_object = null
var kill_distance = 20
var dir = Vector2()
var has_collided = false
var player = null
var rope = null
var stop_at = null


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
			free_hook()
	elif pulling_object:
		dir = (player.position - self.position).normalized()
		position += dir * (delta * speed * .3)
		if position.distance_to(player.position) <= kill_distance:
			pulling_object.removeHook()
			free_hook()


func is_pulling_object():
	return pulling_object


func is_colliding():
	return has_collided


func shoot(direction):
	dir = direction


func hit_hook(otherHook):
	retract()
	player.map.blink_screen()
	BGM.get_node('HookHitHook').play()
#	camera.add_shake(.8)
	emit_signal("shook_screen", SCREEN_SHAKE_HOOK_HIT)
	hook_clink.position = (otherHook.position + self.position)/2
	hook_clink.emitting = true


func hit_object(object):
#	camera.add_shake(.1)
	emit_signal("shook_screen", SCREEN_SHAKE_OBJECT_HIT)
	has_collided = true
	object.setHook(self)
	pulling_object = object


func hit_shark(Shark):
	if not Shark.stunned and not Shark.diving:
		$BloodParticles.emitting = true
		stop_at = Shark
		Shark.hook_collision(self)
		BGM.get_node('HookHitPlayer').play()
#		camera.add_shake(.7)
		emit_signal("shook_screen", SCREEN_SHAKE_SHARK_HIT)


func hit_wall():
	$WallParticles.emitting = true
#	camera.add_shake(.3)
	emit_signal("shook_screen", SCREEN_SHAKE_WALL_HIT)
	has_collided = true
	BGM.get_node('HookHitWall').play()


func retract():
	if pulling_object:
		pulling_object = null
	retracting = true


func free_hook():
	rope.queue_free()
	player.hook = null
	pulling_object = null
	self.queue_free()


func _on_HookArea_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('object') and not retracting:
		hit_object(object)
	elif object.is_in_group('hook') and not retracting:
		hit_hook(object)
	elif object.is_in_group('wall') and not retracting:
		hit_wall()
	elif object.is_in_group('player') and object != player and not retracting:
		hit_shark(object)
