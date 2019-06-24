extends "res://gameplay/objects/powerups/GenericPower.gd"

const MEGAHOOK_SPRITE = preload("res://assets/images/elements/megahook.png")

var player
var speed = 1400
var direction = Vector2()


func _physics_process(delta):
	position += direction * speed * delta


func init(player):
	if not player.get_node("PowerUps").has_node("MegaHook"):
		self.player = player
		player.riders_hook.texture = MEGAHOOK_SPRITE
		player.riders_hook.scale = Vector2(2,2)
		player.riders_hook.offset = Vector2(-70,0)
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
	$ShootSFX.play()
	$HookArea/CollisionShape2D.set_disabled(false)
	set_physics_process(true)


func explode():
	set_physics_process(false)
	$HookArea/CollisionShape2D.set_deferred("disabled", true)
	$Sprite.hide()
	
	$MegahookExplosion.emitting = true
	$ExplosionSFX.play()
	yield(get_tree().create_timer($MegahookExplosion.lifetime), "timeout")
	queue_free()


func deactivate():
	queue_free()


func free_hook():
	queue_free()


func _on_MegaHookArea_area_entered(area):
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			var other_player = area.get_parent().get_parent()
			if other_player != player and not other_player.diving and not other_player.invincible:
				other_player.die(true)
				queue_free()
		Collision.OBSTACLE:
			explode()
		Collision.FLOATING_OBSTACLE:
			explode()
		Collision.HOOK:
			explode()
