extends Node2D

onready var initial_position = position

const infinite_dive = preload("res://objects/Powerups/InfiniteDive.tscn")
const megahook = preload("res://objects/Powerups/MegaHook.tscn")
const trail_power = preload("res://objects/Powerups/TrailPower.tscn")

const oxygen_barrel = preload("res://assets/barrelo2.png")
const wooden_barrel = preload("res://assets/barrel2.png")
const metal_barrel = preload("res://assets/Barrel3.png")

const ob_shader = preload("res://assets/barrelo2_o.png")
const wb_shader = preload("res://assets/barrel2_o.png")
const mb_shader = preload("res://assets/Barrel3_o.png")

const wooden_particle = preload("res://assets/barril_quebrando_particula.png")
const metal_particle = preload("res://assets/metalbarrel_particle.png")


const POWERS = [infinite_dive,
				megahook,
                trail_power]
				
const CRATES = [oxygen_barrel,
				wooden_barrel,
                metal_barrel]

const SHADERS = [ob_shader,
				 wb_shader,
                 mb_shader]
				
const PARTICLES = [wooden_particle,
				   wooden_particle,
                   metal_particle]

export(PackedScene) var powerup

var random = false
var hook


func _ready():
	randomize()
	$Hitbox.disconnect("area_entered", self, "_on_Hitbox_area_entered")
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
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Sprite2.set_modulate(Color(1, 1, 1, 0))
	$Sprite2/AnimationPlayer.stop()
	$Sprite.set_modulate(Color(1, 1, 1, 0))
	$Sprite/AnimationPlayer.stop()
	$Particles2D.emitting = true
	$Sprite.hide()
	$Sprite2.hide()
	


func spawn():
	if random:
		set_random_power()
	position = initial_position
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	$Sprite2/AnimationPlayer.play("spawn")
	$Sprite/AnimationPlayer.play("spawn")
	$Sprite.show()
	$Sprite2.show()
	


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
	$Sprite.set_texture(CRATES[index])
	$Sprite2.set_texture(SHADERS[index])
	$Particles2D.set_texture(PARTICLES[index])
	

