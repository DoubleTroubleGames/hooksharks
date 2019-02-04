extends Node2D

onready var camera = get_node('../../Camera2D')
onready var bgm = get_node('/root/BGM')
onready var hook_clink = get_node('../../HookClink')

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

func isPullingObject():
	return not not pulling_object

func isColliding():
	return has_collided

func shoot(direction):
	dir = direction

func hookHitHook(otherHook):
	retract()
	player.map.blink_screen()
	BGM.get_node('HookHitHook').play()
	camera.add_shake(.8)
	hook_clink.position = (otherHook.position + self.position)/2
	hook_clink.emitting = true

func hookHitShark(Shark):
	if not Shark.stunned and not Shark.diving:
		$BloodParticles.emitting = true
		stop_at = Shark
		Shark.hook_collision(self)
		BGM.get_node('HookHitPlayer').play()
		camera.add_shake(.7)

func hookHitWall():
	$WallParticles.emitting = true
	camera.add_shake(.3)
	has_collided = true
	BGM.get_node('HookHitWall').play()

func hookHitObject(object):
	camera.add_shake(.1)
	has_collided = true
	object.setHook(self)
	pulling_object = object

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
		hookHitObject(object)
	elif object.is_in_group('hook') and not retracting:
		hookHitHook(object)
	elif object.is_in_group('wall') and not retracting:
		hookHitWall()
	elif object.is_in_group('player') and object != player and not retracting:
		hookHitShark(object)