extends "res://gameplay/objects/powerups/GenericPower.gd"

const MEGAHOOK_SPRITE = preload("res://assets/images/elements/megahook.png")

var player
var speed = 800
var direction = Vector2()


func _physics_process(delta):
	position += direction * speed * delta


func init(player):
	if not player.get_node("PowerUps").has_node("MegaHook"):
		self.player = player
		player.riders_hook.texture = MEGAHOOK_SPRITE
		set_physics_process(false)
		hide()
		return true
	else:
		queue_free()
		return false


func activate(direction):
	var angle = Vector2(cos(player.sprite.rotation), sin(player.sprite.rotation))
	self.direction = direction
	self.global_position = player.get_global_position() + player.rider_offset * angle
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
