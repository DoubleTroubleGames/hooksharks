extends Node2D

signal hook_clinked(position)
signal wall_hit(position, rotation)
signal shook_screen(amount)

const SCREEN_SHAKE_HOOK_HIT = .8
const SCREEN_SHAKE_OBJECT_HIT = .1
const SCREEN_SHAKE_SHARK_HIT = .7
const SCREEN_SHAKE_WALL_HIT = .3

var speed = 700
var acc = 500
var retracting = false
var pulling_object = null
var kill_distance = 20
var direction = Vector2()
var has_collided = false
var player = null
var rope = null
var stop_at = null


func init(player, direction):
	var angle = Vector2(cos(player.rotation), sin(player.rotation))
	self.player = player
	self.direction = direction
	self.position = player.position
	self.position += player.RIDER_OFFSET * angle
	$Sprite.rotation = direction.angle()


func _physics_process(delta):
	speed += acc * delta
	if stop_at != null:
		position = stop_at.position
	elif !has_collided:
		position += direction * (delta * speed)
	if retracting:
		direction = (player.position - self.position).normalized()
		position += direction * (delta * speed * 2)
		if position.distance_to(player.position) <= kill_distance:
			free_hook()
	elif pulling_object:
		direction = (player.position - self.position).normalized()
		position += direction * (delta * speed * .3)
		if position.distance_to(player.position) <= kill_distance:
			pulling_object.removeHook()
			if pulling_object.is_in_group('powerup'):
				pulling_object.activate(player)
			free_hook()


func is_pulling_object():
	return pulling_object


func is_colliding():
	return has_collided


func hit_hook(other_hook):
	retract()
	emit_signal("shook_screen", SCREEN_SHAKE_HOOK_HIT)
	emit_signal("hook_clinked", (other_hook.position + self.position) / 2)


func hit_object(object):
	emit_signal("shook_screen", SCREEN_SHAKE_OBJECT_HIT)
	has_collided = true
	object.setHook(self)
	pulling_object = object


func hit_shark(shark):
	if not shark.stunned and not shark.diving:
		stop_at = shark
		shark.hook_collision(self)
		emit_signal("shook_screen", SCREEN_SHAKE_SHARK_HIT)


func hit_wall():
	emit_signal("shook_screen", SCREEN_SHAKE_WALL_HIT)
	emit_signal("wall_hit", position, $Sprite.rotation - PI)
	has_collided = true


func retract():
	if pulling_object:
		pulling_object.removeHook()
		pulling_object = null
	retracting = true


func free_hook():
	rope.queue_free()
	if pulling_object:
		pulling_object.removeHook()
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
