extends Node2D

var player
var speed = 2
var acc = 4
var direction = Vector2()

func _ready():
	set_physics_process(false)

func init(_player):
	if not _player.get_node("PowerUps").has_node("MegaHook"):
		return true
	else:
		queue_free()
		return false

func activate(player, direction):
	self.player = player
	self.direction = direction
	self.position = player.position
	$Sprite.rotation = direction.angle()

	show()
	$HookArea/CollisionShape2D.set_disabled(false)
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
			object.die()
			queue_free()
	elif object.is_in_group('wall') or object.is_in_group('hook'):
		queue_free()
