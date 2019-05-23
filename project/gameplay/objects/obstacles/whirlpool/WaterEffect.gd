tool
extends Node2D

func _draw():
	var radius = get_parent().whirl_size
	draw_circle(Vector2(0,0), radius, Color(0,0,0))