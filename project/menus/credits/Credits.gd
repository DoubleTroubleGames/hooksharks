extends Control

onready var bar = $BackIndicator/Progress
onready var anim_player = $BackIndicator/AnimationPlayer

var back_indicator_up_speed = 100
var back_indicator_down_speed = 150


func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		bar.value = min(100, bar.value + back_indicator_up_speed*delta)
	else:
		bar.value = max(0, bar.value - back_indicator_down_speed * delta)
	
	if bar.value >= 100:
		Transition.transition_to("ModeSelect")
	elif bar.value > 0:
		if anim_player.assigned_animation != "show":
			anim_player.play("show")
	elif anim_player.assigned_animation == "show":
			anim_player.play("hide")


func _on_transition_in() -> void:
	set_physics_process(false)
	set_process_input(false)
