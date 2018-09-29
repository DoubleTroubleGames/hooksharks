extends Sprite

export (Vector2) var extents

func _ready():
	if extents:
		var shape = RectangleShape2D.new()
		shape.extents = extents
		$Area2D/CollisionShape2D.shape = shape

