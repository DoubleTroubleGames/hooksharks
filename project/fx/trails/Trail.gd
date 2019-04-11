extends Node2D

const WAIT_TIME = 4
const OIL_OPACITY = .7
const OIL_SCALE = .4

onready var sprite = $Oil
onready var tween = $Tween

var can_collide = false

func _ready():
	$Timer.wait_time = WAIT_TIME
	$Timer.start()
	sprite.frame = randi() % sprite.hframes
	tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, OIL_OPACITY), .5,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(sprite, "scale", Vector2(.2, .2), Vector2(OIL_SCALE, OIL_SCALE), .5,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()


func _on_Timer_timeout():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$Fire.emitting = false
	var duration = $Fire.lifetime + .5
	$KillTimer.wait_time = duration
	$KillTimer.start()

	tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, OIL_OPACITY), Color(1, 1, 1, 0), duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(sprite, "scale", Vector2(OIL_SCALE, OIL_SCALE), Vector2(.2, .2), duration,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func _on_KillTimer_timeout():
	self.queue_free()
