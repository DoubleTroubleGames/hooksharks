extends "res://objects/Powerups/GenericPower.gd"

var player
var speed = 800
var direction = Vector2()


func init(_player):
	if not _player.get_node("PowerUps").has_node("MegaHook"):
		return true
	else:
		queue_free()
		return false


func activate(player, direction):
	var angle = Vector2(cos(player.sprite.rotation), sin(player.sprite.rotation))
	self.player = player
	self.direction = direction
	self.position = player.position + player.rider_offset * angle
	$Sprite.rotation = Vector2(-direction.x, -direction.y).angle()

	show()
	$HookArea/CollisionShape2D.set_disabled(false)
	set_physics_process(true)


func _physics_process(delta):
	position += direction * speed * delta


func _on_MegaHookArea_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('player'):
		if (object != player) and (!object.diving):
			object.die()
			queue_free()
	elif object.is_in_group('wall') or object.is_in_group('hook'):
		queue_free()


func free_hook():
	queue_free()
