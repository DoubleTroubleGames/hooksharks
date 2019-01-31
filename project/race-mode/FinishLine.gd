extends Node2D


func _ready():
	$Direction.hide()


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var winner = area.get_parent()
		var players = winner.get_parent()
		
		for child in players.get_children():
			if child.is_in_group('player') and child != winner:
				child._queue_free()
