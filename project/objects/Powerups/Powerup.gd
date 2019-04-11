extends Node2D

onready var initial_position = position

const POWERS = [preload("res://objects/Powerups/InfiniteDive.tscn"),
				preload("res://objects/Powerups/MegaHook.tscn"),
                preload("res://objects/Powerups/TrailPower.tscn")]
				
const CRATES = ["barrel2",
				"barrel2",
                "Barrel3"]

export(PackedScene) var powerup

var random = false
var hook


func _ready():
	randomize()
	if not powerup:
		random = true
		set_random_power()


func _physics_process(delta):
	if hook:
		position = hook.position


func set_hook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook


func remove_hook():
	hook = null


func despawn():
	$Hitbox/CollisionShape2D.set_disabled(true)
	$Sprite2.set_modulate(Color(1, 1, 1, 0))
	$Sprite2/AnimationPlayer.stop()
	$Sprite.set_modulate(Color(1, 1, 1, 0))
	$Sprite/AnimationPlayer.stop()
	hide()


func spawn():
	if random:
		set_random_power()
	position = initial_position
	$Hitbox/CollisionShape2D.set_disabled(false)
	$Sprite2/AnimationPlayer.play("spawn")
	$Sprite/AnimationPlayer.play("spawn")
	show()


func activate(player):
	var power = powerup.instance()
	# If initialized sucessfully, add it to player
	if power.init(player):
		player.get_node("PowerUps").add_child(power)
		player.add_label(power.power_name)
	if hook:
		hook.free_hook()
	
	despawn()
	$RespawnTimer.start()


func set_random_power():
	var index = randi() % POWERS.size()
	powerup = POWERS[index]
	$Sprite.set_texture(load(str("res://assets/", CRATES[index], ".png")))
	$Sprite2.set_texture(load(str("res://assets/", CRATES[index], "_o.png")))
	

