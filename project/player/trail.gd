extends Node2D

var can_collide = false

func _ready():
	$Timer.start()
	
	


func _on_Timer_timeout():
	$Fire.emitting = false
	$KillTimer.start()


func _on_KillTimer_timeout():
	self.queue_free()
