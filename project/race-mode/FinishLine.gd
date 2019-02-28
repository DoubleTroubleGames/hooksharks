tool

extends Node2D

const WIDTH = 10

export (int)var size = 300 setget set_size
export (int)var last_checkpoint_number
export (int)var total_laps = 1

func _draw():
#	var rect = Rect2(0, 0, 10, 300)
#	draw_rect(rect, Color(1, 1, 1))
	var PullTop_pos = $PullableObjectTop.get_position()
	var PullBot_pos = $PullableObjectBot.get_position()
	var polygon = PoolVector2Array([Vector2(PullTop_pos.x - WIDTH, PullTop_pos.y),
								   Vector2(PullTop_pos.x + WIDTH, PullTop_pos.y),
								   Vector2(PullBot_pos.x + WIDTH, PullBot_pos.y),
								   Vector2(PullBot_pos.x - WIDTH, PullBot_pos.y)])
	var color_array = [Color(1, 1, 1), Color(0, 0, 0), Color(1, 1, 1), Color(0, 0, 0)]
	draw_polygon(polygon, color_array)


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var player = area.get_parent()
		if player.checkpoint_number == last_checkpoint_number:
			player.lap += 1
			if player.lap >= total_laps:
				var winner = player
				var players = winner.get_parent()
				
				$Area2D.queue_free()
				for child in players.get_children():
					if child.is_in_group('player') and child != winner:
						child._queue_free()
		player.checkpoint_number = 0


func set_size(s):
	size = s
	if $Area2D:
		var shape = RectangleShape2D.new()
		shape.set_extents(Vector2(WIDTH, size))
		$Area2D/CollisionShape2D.set_shape(shape)
		$PullableObjectTop.set_position(Vector2(0, -size))
		$PullableObjectBot.set_position(Vector2(0, size))