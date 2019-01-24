extends Node2D

var speed = 700
var acc = 500
var retracting = false
var kill_distance = 20 # distance to delete hook when retracting

onready var camera = get_node('../../Camera2D')
onready var hook_clink = get_node('../../HookClink')
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
			free_hook()

func _on_HookArea_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('hook') and not retracting:
		hookHitHook()
	elif object.is_in_group('player') and object != player and not retracting:
		hookHitShark()
	elif object.is_in_group('wall') and not retracting:
		hookHitWall()

func hookHitHook():
	retract()
	player.map.blink_screen()
	Bgm.get_node('HookHitHook').play()
	camera.add_shake(.8)
	hook_clink.position = (object.position + self.position)/2
	hook_clink.emitting = true

func hookHitShark():
	if not object.stunned and not object.diving:
		$BloodParticles.emitting = true
		stop_at = object
		object.hook_collision(self)
		Bgm.get_node('HookHitPlayer').play()
		camera.add_shake(.7)

func hookHitWall():
	$WallParticles.emitting = true
	camera.add_shake(.3)
	has_collided = true
	Bgm.get_node('HookHitWall').play()

func retract():
	retracting = true

func free_hook():
	rope.queue_free()
	player.hook = null
	self.queue_free()
