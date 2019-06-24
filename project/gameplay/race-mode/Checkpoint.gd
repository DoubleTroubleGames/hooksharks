extends Node2D

onready var stage = get_parent().get_parent()

export(int, 1, 20, 1) var number = 1


func get_respawn_position(player_number):
	return get_node("Pos" + str(player_number)).get_global_position()


func _on_Area2D_area_entered(area):
	if area.collision_layer == Collision.PLAYER_ABOVE:
		var player = area.get_parent().get_parent()
		if not player.is_respawning:
			var checkpoint_num = stage.get_player_checkpoint(player)
			if checkpoint_num == number - 1:
				stage.increase_player_checkpoint(player)
			elif not player.invincible and not player.dont_collide:
				player.add_label("Wrong Way")
