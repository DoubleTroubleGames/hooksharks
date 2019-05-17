extends "res://gameplay/objects/PullableObject.gd"

export(String) var power_name = "Powerup"
var player


func _physics_process(delta):
	var angle = player.sprite.rotation
	rotation = angle
	position = Vector2(-200 * cos(angle), -200 * sin(angle)) 
	

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
	$Hitbox.monitoring = true
	$Hitbox.monitorable = true


func activate():
	set_physics_process(false)
	$Timer.start()
	yield($Timer, "timeout")
	explode()


func deactivate():
	queue_free()


func explode():
	print("exploded")


func _on_Hitbox_area_entered(area):
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			explode()
		Collision.OBSTACLE:
			explode()
		Collision.FLOATING_OBSTACLE:
			explode()
