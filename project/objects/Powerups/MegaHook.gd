extends "res://objects/Powerups/GenericPower.gd"

var player
var speed = 800
var direction = Vector2()


func _physics_process(delta):
	position += direction * speed * delta


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

func deactivate():
	queue_free()

func free_hook():
	queue_free()


func _on_MegaHookArea_area_entered(area):
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			var other_player = area.get_parent().get_parent()
			if other_player != player and not other_player.diving:
				other_player.die()
				queue_free()
		Collision.OBSTACLE:
			queue_free()
		Collision.FLOATING_OBSTACLE:
			queue_free()
		Collision.HOOK:
			queue_free()
