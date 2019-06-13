extends "res://gameplay/objects/PullableObject.gd"

const FOLLOW_DIST = 130

export(String) var power_name = "Powerup"
var player


func _physics_process(delta):
	var angle = player.sprite.rotation
	rotation = angle
	position = Vector2(-FOLLOW_DIST * cos(angle), -FOLLOW_DIST * sin(angle)) 
	

func init(_player):
	if not _player.get_node("PowerUps").has_node("WaterMine"):
		self.player = _player
		spawn()
		set_physics_process(true)
		return true
	else:
		queue_free()
		return false


func spawn():
	$AnimationPlayer.play("spawn")
	yield($AnimationPlayer, "animation_finished")
	$Hitbox/CollisionShape2D.disabled = false


func activate():
	var angle = player.sprite.rotation
	set_physics_process(false)
	set_position(player.get_global_position() + Vector2(-FOLLOW_DIST * cos(angle), -FOLLOW_DIST * sin(angle)))
	$Rope.queue_free()
	$Timer.start()
	yield($Timer, "timeout")
	explode()


func deactivate():
	queue_free()


func explode():
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("pulse")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("explode")
	$SFXExplosion.play()
	yield($AnimationPlayer, "animation_finished")
	queue_free()


func _on_Hitbox_area_entered(area):
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			explode()
		Collision.OBSTACLE:
			explode()
		Collision.FLOATING_OBSTACLE:
			explode()
		Collision.HOOK:
			explode()


func _on_ExplosionArea_area_entered(area):
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			var player = area.get_parent().get_parent()
			if not player.invincible:
				player.die()
		Collision.PLAYER_BELOW:
			var player = area.get_parent().get_parent()
			if not player.invincible:
				player.die()
