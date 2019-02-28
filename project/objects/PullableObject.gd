extends Node2D

signal hooked
signal unhooked

var hook


func _ready():
	set_physics_process(false)

func _physics_process(delta):
	position = hook.position

func setHook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook
	set_physics_process(true)

func removeHook():
	hook = null
	set_physics_process(false)
