extends Node2D

var player
var speed = 4
var acc = 2
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
	var angle = Vector2(cos(player.rotation), sin(player.rotation))
	self.player = player
	self.direction = direction
	self.position = player.position
	$Sprite.rotation = direction.angle()

	show()
	$HookArea/CollisionShape2D.set_disabled(false)
	set_physics_process(true)

func _physics_process(delta):
	speed += acc * delta
	position += direction * (delta * speed)

func _on_MegaHookArea_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group('player'):
		if (object != player) and (!object.diving):
			object.die()
			queue_free()
	elif object.is_in_group('wall') or object.is_in_group('hook'):
		queue_free()

func free_hook():
	queue_free()