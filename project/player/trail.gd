extends Node2D

const WAIT_TIME = 4

var can_collide = false

func _ready():
	$Timer.wait_time = WAIT_TIME
	$Timer.start()


func _on_Timer_timeout():
	$Area2D/CollisionShape2D.disabled = true
	$Fire.emitting = false
	$KillTimer.wait_time = $Fire.lifetime + .5
	$KillTimer.start()


func _on_KillTimer_timeout():
	self.queue_free()
