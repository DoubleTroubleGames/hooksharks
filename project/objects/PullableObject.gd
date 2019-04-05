extends Node2D

signal hooked
signal unhooked

const MIN_DIST = 115

var hook


func _physics_process(delta):
	if hook:
		set_global_position(hook.get_global_position())

func set_hook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook
	emit_signal("hooked")
	$Timer.start()

func remove_hook():
	hook = null

func _on_Timer_timeout():
	if hook:
		emit_signal("unhooked")
		hook.retract()
		remove_hook()


func _on_Hitbox_area_entered(area):
	# This area only monitors other pullable objects.
	var other_pullable = area.get_parent()
	if other_pullable.get_parent() == self.get_parent():
		var dist = self.global_position - other_pullable.global_position
		var diff = MIN_DIST - min(dist.length(), MIN_DIST)
		
		self.global_position += diff * dist.normalized()
		
		if hook:
			hook.retract()
