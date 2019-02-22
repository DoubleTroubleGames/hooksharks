extends Node2D

export (PackedScene)var powerup
var hook

func _physics_process(delta):
	if hook:
		position = hook.position

func setHook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook

func removeHook():
	hook = null	

func activate(player):
	var power = powerup.instance()
	power.init(player)
	player.add_child(power)
	queue_free()
	