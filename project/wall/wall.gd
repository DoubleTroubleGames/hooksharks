extends Node2D

func _ready():
	get_node('Left/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(24, 0), Vector2(24, OS.window_size.y), Vector2(0, OS.window_size.y)])
	get_node('Right/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(24, 0), Vector2(24, OS.window_size.y), Vector2(0, OS.window_size.y)])
	get_node('Right').position = Vector2(OS.window_size.x - 24, 0)
	get_node('Top/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(OS.window_size.x, 0), Vector2(OS.window_size.x, 24), Vector2(0, 24)])
	get_node('Bottom/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(OS.window_size.x, 0), Vector2(OS.window_size.x, 24), Vector2(0, 24)])
	get_node('Bottom').position = Vector2(0, OS.window_size.y - 24)
