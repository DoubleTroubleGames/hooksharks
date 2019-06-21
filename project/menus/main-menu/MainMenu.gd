extends Control

onready var camera = $Camera2D
onready var title = $Title
onready var tween = $Tween
onready var title_pos = title.rect_position
onready var bar = $BackIndicator/Progress
onready var anim_player = $BackIndicator/AnimationPlayer

const TITLE_OFFSET = Vector2(5000, 0)
const TITLE_DELAY = .5
const GLOW_DURATION = 1

export (PackedScene)var ModeSelect

var title_shown = false
var back_indicator_up_speed = 50
var back_indicator_down_speed = 50


func _ready():
	$BackIndicator/Message.text = "Hold to quit"
	title.rect_position = title.rect_position -\
			TITLE_OFFSET.rotated(deg2rad(title.rect_rotation))
	
	if Transition.is_black_screen:
		Transition.transition_out()
		yield(Transition, "finished")
	
	tween.interpolate_property(title, "rect_position", null, title_pos, 1.5,
			Tween.TRANS_LINEAR, Tween.EASE_OUT, TITLE_DELAY)
	tween.start()
	$TitleAnticipationSFX.play()

	yield(tween, "tween_completed")
	show_title()
	
	randomize()
	$PressStartTimer.start()


func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if event.is_action_pressed("ui_start"):
		if not title_shown:
			show_title()
		else:
			change_screen()


func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		bar.value = min(100, bar.value + back_indicator_up_speed*delta)
	else:
		bar.value = max(0, bar.value - back_indicator_down_speed * delta)
	
	if bar.value >= 100:
		get_tree().quit()
	elif bar.value > 0:
		if anim_player.assigned_animation != "show":
			anim_player.play("show")
	elif anim_player.assigned_animation == "show":
			anim_player.play("hide")


func show_title():
	if title_shown:
		return
	
	title_shown = true

	tween.stop_all()
	title.rect_position = title_pos
	$TitleAnticipationSFX.stop()
	
	$TitleAppearSFX.play()
	
	tween.interpolate_property($CanvasLayer/ScreenGlow, "modulate:a", 1, 0,
			GLOW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	camera.add_shake(1)
	
	$PressStartTimer.start()


func change_screen():
	$StartPressSFX.play()
	
	Transition.transition_in()
	set_process_input(false)
	yield(Transition, "finished")
	get_tree().change_scene_to(ModeSelect)


func _on_PressStartTimer_timeout():
	$PressStartShowSFX.play()
	$PressStart/AnimationPlayer.play("show")
