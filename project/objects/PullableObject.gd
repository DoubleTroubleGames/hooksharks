extends Node2D

signal hooked
signal unhooked

var hook


func _physics_process(delta):
	if hook:
		set_global_position(hook.get_global_position())

func setHook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook

func removeHook():
	hook = null
