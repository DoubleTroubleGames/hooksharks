extends Control

onready var bar = $BackIndicator/Progress
onready var anim_player = $BackIndicator/AnimationPlayer

var back_indicator_up_speed = 100
var back_indicator_down_speed = 150

func _ready():
	Transition.transition_out()


func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		bar.value = min(100, bar.value + back_indicator_up_speed*delta)
	else:
		bar.value = max(0, bar.value - back_indicator_down_speed * delta)
	
	if bar.value >= 100:
		set_physics_process(false)
		set_process_input(false)
		Transition.transition_in()
		yield(Transition, "finished")
		get_tree().change_scene_to(load("res://menus/mode-select/ModeSelect.tscn"))
	elif bar.value > 0:
		if anim_player.assigned_animation != "show":
			anim_player.play("show")
	elif anim_player.assigned_animation == "show":
			anim_player.play("hide")
