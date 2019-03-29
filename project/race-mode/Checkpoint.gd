extends Node2D

onready var Stage = get_parent().get_parent()

export(int, 1, 20, 1) var number = 1

func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var Player = area.get_parent()
		var checkpoint_num = Stage.get_player_checkpoint(Player)
		if checkpoint_num == number - 1:
			Stage.increase_player_checkpoint(Player)

func get_respawn_position(player_number):
	return get_node("Pos" + str(player_number)).get_global_position()