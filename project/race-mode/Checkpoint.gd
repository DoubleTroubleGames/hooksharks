extends Node2D

export(int, 1, 20, 1) var number = 1

func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var player = area.get_parent()
		if player.checkpoint_number == number - 1:
			player.checkpoint_number = number

func get_respawn_position(player_number):
	return get_node("Pos" + player_number).position