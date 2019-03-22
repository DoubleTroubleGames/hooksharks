extends Node2D

export (PackedScene)var powerup

const POWERS = [preload("res://objects/Powerups/MegaHook.tscn"),
                preload("res://objects/Powerups/TrailPower.tscn")]

var hook
onready var initial_position = position

func _ready():
	if (powerup == null):
		set_random_power()

func _physics_process(delta):
	if hook:
		position = hook.position

func setHook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook

func removeHook():
	hook = null
	
func despawn():
	$Hitbox/CollisionShape2D.set_disabled(true)
	$Sprite.set_modulate(Color(1, 1, 1, 0))
	$Sprite/AnimationPlayer.stop()
	hide()

func spawn():
	set_random_power()
	position = initial_position
	$Hitbox/CollisionShape2D.set_disabled(false)
	$Sprite/AnimationPlayer.play("spawn")
	show()
	
func set_random_power():
	var index = randi() % POWERS.size()
	powerup = POWERS[index]
	
func activate(player):
	var power = powerup.instance()
	# If initialized sucessfully, add it to player
	if power.init(player):
		player.get_node("PowerUps").add_child(power)
	if hook:
		hook.free_hook()
	
	despawn()
	$RespawnTimer.start()
	