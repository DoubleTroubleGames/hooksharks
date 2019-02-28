extends Node2D

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
