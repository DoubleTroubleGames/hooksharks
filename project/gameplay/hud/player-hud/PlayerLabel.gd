extends Control

const LERP_FACTOR = .2

var is_showing = false

func _physics_process(delta):
	if is_showing:
		modulate.a = lerp(modulate.a, 1, LERP_FACTOR)
	else:
		modulate.a = lerp(modulate.a, 0, LERP_FACTOR)