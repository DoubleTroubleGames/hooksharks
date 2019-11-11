extends Node2D

onready var stage = get_parent().get_parent()

export(int, 1, 20, 1) var number = 1


func get_respawn_position(player_number):
	return get_node("Pos" + str(player_number)).get_global_position()


func _on_Area2D_area_entered(area):
	if area.collision_layer == Collision.PLAYER_ABOVE:
		var player = area.get_parent().get_parent()
		if not player.is_respawning:
			var checkpoint = stage.get_player_checkpoint(player)
			if checkpoint.number == number - 1:
				stage.update_player_checkpoint(player, self)
			elif not player.invincible and not player.dont_collide:
				player.add_label("Wrong Way")
