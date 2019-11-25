extends Node2D

onready var initial_position = position

const infinite_dive = preload("res://gameplay/objects/powerups/InfiniteDive.tscn")
const megahook = preload("res://gameplay/objects/powerups/MegaHook.tscn")
const trail_power = preload("res://gameplay/objects/powerups/TrailPower.tscn")

const oxygen_barrel = preload("res://assets/images/powerup/barrelo2.png")
const wooden_barrel = preload("res://assets/images/powerup/barrelo3.png")
const metal_barrel = preload("res://assets/images/powerup/Barrel3.png")

const ob_shader = preload("res://assets/images/powerup/barrelo2_o.png")
const wb_shader = preload("res://assets/images/powerup/barrel2_o.png")
const mb_shader = preload("res://assets/images/powerup/Barrel3_o.png")

const wooden_particle = preload("res://assets/images/powerup/barril_quebrando_particula.png")
const metal_particle = preload("res://assets/images/powerup/metalbarrel_particle.png")


const POWERS = [infinite_dive, megahook, trail_power]
const CRATES = [oxygen_barrel, wooden_barrel, metal_barrel]
const SHADERS = [ob_shader, wb_shader, mb_shader]
const PARTICLES = [wooden_particle, wooden_particle, metal_particle]
onready var break_sfx = [$WoodBreakSFX, $WoodBreakSFX, $MetalBreakSFX]
onready var hooked_sfx = [$WoodHookedSFX, $WoodHookedSFX, $MetalHookedSFX]

export(PackedScene) var powerup

var current_index = 0
var random = false
var hook


func _ready():
	$Hitbox.disconnect("area_entered", self, "_on_Hitbox_area_entered")
	if not powerup:
		random = true
		set_random_power()
	else:
		for i in POWERS.size():
			if powerup.resource_path == POWERS[i].resource_path:
				current_index = i
	
	$Sprite.set_texture(CRATES[current_index])
	$Sprite2.set_texture(SHADERS[current_index])
	$Particles2D.set_texture(PARTICLES[current_index])


func _physics_process(delta):
	if hook and is_instance_valid(hook):
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
	$Sprite.set_texture(CRATES[current_index])
	$Sprite2.set_texture(SHADERS[current_index])
	$Particles2D.set_texture(PARTICLES[current_index])
	position = initial_position
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	$Sprite2/AnimationPlayer.play("spawn")
	$Sprite/AnimationPlayer.play("spawn")
	$Sprite.show()
	$Sprite2.show()


func add_powerup(player):
	var power = powerup.instance()
	
	if power.init(player):
		player.get_node("PowerUps").call_deferred("add_child", power)
		var color = Color.white
		if power is TrailPower:
			color = Color8(255, 183, 183)
		elif power is InfiniteDive:
			color = Color8(194, 234, 255)
		player.add_label(power.power_name, color)
		$PowerPickup.play()
	if hook and is_instance_valid(hook) and hook.has_method("free_hook"):
		# workaround for weird bug where a trail was being assigned to the hook 
		hook.free_hook()
	
	despawn()
	$RespawnTimer.start()


func set_random_power():
	current_index = randi() % POWERS.size()
	powerup = POWERS[current_index]


func _on_PowerupHitbox_area_entered(area):
	match area.collision_layer:
		Collision.HOOK:
			hooked_sfx[current_index].play()
		Collision.PLAYER_ABOVE:
			break_sfx[current_index].play()
