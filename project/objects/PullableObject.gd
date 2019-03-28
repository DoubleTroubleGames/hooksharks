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
	emit_signal("hooked")
	$Timer.start()

func removeHook():
	hook = null

func _on_Timer_timeout():
	if hook:
		emit_signal("unhooked")
		hook.retract()
		removeHook()
