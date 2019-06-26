extends Node2D

signal hook_clinked(position)
signal wall_hit(position, rotation, color)
signal shook_screen(amount)

const SCREEN_SHAKE_HOOK_HIT = .8
const SCREEN_SHAKE_OBJECT_HIT = .1
const SCREEN_SHAKE_SHARK_HIT = .7
const SCREEN_SHAKE_WALL_HIT = .3
const SPEED_MOD = .5

var speed = 500
var acc = 500
var retracting = false
var pulling_object = null
var kill_distance = 20
var direction = Vector2()
var has_collided = false
var player = null
var rope = null
var stop_at = null
var sprite


func init(player, direction):
	var angle = Vector2(cos(player.sprite.rotation), sin(player.sprite.rotation))
	self.player = player
	self.direction = direction
	self.position = player.position
	self.position += player.rider_offset * angle
	self.speed += self.player.speed2.length()*SPEED_MOD
	sprite = get_node(RoundManager.character_map[player.id].capitalize())
	sprite.visible = true
	sprite.rotation = direction.angle()


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
			pulling_object.remove_hook()
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
	
	rope.straighten()


func hit_object(object):
	emit_signal("shook_screen", SCREEN_SHAKE_OBJECT_HIT)
	has_collided = true
	if not pulling_object:
		object.set_hook(self)
		pulling_object = object
	
	rope.straighten()


func hit_shark(shark):
	if not shark.stunned and not shark.diving and not shark.invincible:
		stop_at = shark
		shark.hook_collision(self)
		emit_signal("shook_screen", SCREEN_SHAKE_SHARK_HIT)
		
		rope.straighten()


func hit_wall(color):
	emit_signal("shook_screen", SCREEN_SHAKE_WALL_HIT)
	emit_signal("wall_hit", position, sprite.rotation - PI, color)
	has_collided = true
	
	rope.straighten()


func retract():
	if pulling_object:
		pulling_object.remove_hook()
		pulling_object = null
	retracting = true
	$RetractSFX.play()
	rope.straighten(false)


func free_hook():
	rope.queue_free()
	if pulling_object:
		pulling_object.remove_hook()
	player.hook_retracted()
	pulling_object = null
	self.queue_free()


func _on_HookArea_area_entered(area):
	if retracting:
		return
	
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			var shark = area.get_parent().get_parent()
			if shark != player:
				hit_shark(shark)
		Collision.OBSTACLE:
			hit_wall(area.color)
		Collision.FLOATING_OBSTACLE:
			hit_wall(area.color)
		Collision.POWERUP:
			hit_object(area.get_parent())
		Collision.HOOK:
			hit_hook(area.get_parent())
		Collision.MEGAHOOK:
			hit_hook(area.get_parent())
		Collision.PULLABLE_OBJECT:
			hit_object(area.get_parent())


func _on_RetractSFX_finished():
	$RetractSFX.pitch_scale *= 1.1
	$RetractSFX.play()
