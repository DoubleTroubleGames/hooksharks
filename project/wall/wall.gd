extends Node2D

func _ready():
	get_node('Left/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(24, 0), Vector2(24, 720), Vector2(0, 720)])
	get_node('Right/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(24, 0), Vector2(24, 720), Vector2(0, 720)])
	get_node('Right').position = Vector2(1280 - 24, 0)
	get_node('Top/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 24), Vector2(0, 24)])
	get_node('Bottom/CollisionPolygon2D').polygon = PoolVector2Array([Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 24), Vector2(0, 24)])
	get_node('Bottom').position = Vector2(0, 720 - 24)
