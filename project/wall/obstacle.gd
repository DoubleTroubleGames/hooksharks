extends Node2D

onready var sprite = $Sprite
onready var area_polygon = $Area2D/CollisionPolygon2D

func _ready():
	var sprite_size = Vector2(abs(area_polygon.polygon[1].x - area_polygon.polygon[0].x), abs(area_polygon.polygon[2].y - area_polygon.polygon[1].y))
	sprite.scale = sprite_size/sprite.texture.get_size()
	sprite.position = area_polygon.polygon[0] + sprite_size/2
