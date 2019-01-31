tool

extends Node2D

export (int)var size = 300 setget set_size


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var winner = area.get_parent()
		var players = winner.get_parent()
		
		for child in players.get_children():
			if child.is_in_group('player') and child != winner:
				child._queue_free()


func set_size(s):
	size = s
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(10, size))
	$Area2D/CollisionShape2D.set_shape(shape)