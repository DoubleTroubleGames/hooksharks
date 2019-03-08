extends Node2D

var player
var speed = 2
var acc = 4
var direction = Vector2()

func _ready():
	set_physics_process(false)

func init(_player):
	self.player = _player
	if not player.get_node("PowerUps").has_node("MegaHook"):
		return true
	else:
		queue_free()
		return false

func activate(direction):
	self.direction = direction
	position = Vector2()
	$Sprite.rotation = direction.angle()

	show()
	set_physics_process(true)

func _physics_process(delta):
	print(str("Position:", position))
	print(str("Player position:", player.position))
	speed += acc * delta
	position += direction * (delta * speed)

func _on_MegaHookArea_area_entered(area):
	var object = area.get_parent()
	print(object.get_name())
	if object.is_in_group('player'):
		if (object != player) and (!object.diving):
			object._queue_free()
			queue_free()
	elif object != player:
		queue_free()
