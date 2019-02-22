tool

extends Node2D

export (int)var size = 300 setget set_size

export (int)var last_checkpoint_number
export (int)var total_laps = 1


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var player = area.get_parent()
		if player.checkpoint_number == last_checkpoint_number:
			player.lap += 1
			if player.lap >= total_laps:
				var winner = player
				var players = winner.get_parent()
				
				for child in players.get_children():
					if child.is_in_group('player') and child != winner:
						child._queue_free()
		player.checkpoint_number = 0


func set_size(s):
	size = s
	if $Area2D:
		var shape = RectangleShape2D.new()
		shape.set_extents(Vector2(10, size))
		$Area2D/CollisionShape2D.set_shape(shape)