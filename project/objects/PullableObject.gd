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


func _on_Hitbox_area_entered(area):
	if area.get_parent().get_parent() == self.get_parent():
		var dist = self.get_global_position() - area.get_global_position()
		var diff = 115 - min(dist.length(), 115)
		
		self.set_global_position(self.get_global_position() + diff * dist.normalized())
		print(self.global_position)
		if hook:
			hook.retract()
