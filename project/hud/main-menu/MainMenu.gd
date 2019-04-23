extends Control

onready var camera = $Camera2D
onready var title = $Title
onready var subtitle = $Subtitle
onready var tween = $Tween
onready var title_pos = title.rect_position
onready var subtitle_pos = subtitle.rect_position

const TITLE_OFFSET = Vector2(5000, 0)
const TITLE_DELAY = .5
const GLOW_DURATION = 1

export (PackedScene)var ModeSelect

var title_shown = false


func _ready():
	set_process_input(false)
#	title.rect_position = title.rect_position -\
#			TITLE_OFFSET.rotated(deg2rad(title.rect_rotation))
#	subtitle.rect_position = subtitle.rect_position +\
#			TITLE_OFFSET.rotated(deg2rad(title.rect_rotation))
#
	if Transition.is_black_screen:
		Transition.transition_out()
		yield(Transition, "finished")
#
#	tween.interpolate_property(title, "rect_position", null, title_pos, 1.5,
#			Tween.TRANS_LINEAR, Tween.EASE_OUT, TITLE_DELAY)
#	tween.interpolate_property(subtitle, "rect_position", null, subtitle_pos,
#			1.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, TITLE_DELAY)
#	tween.start()
#
#	yield(tween, "tween_completed")
#	show_title()
	set_process_input(true)
	$PressStartTimer.start()


func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if event.is_action_pressed("ui_start"):
		if not title_shown:
			show_title()
#		else:
			change_screen()


func show_title():
	if title_shown:
		return
	
	title_shown = true
	
#	tween.stop_all()
#	title.rect_position = title_pos
#	subtitle.rect_position = subtitle_pos
	
	tween.interpolate_property($CanvasLayer/ScreenGlow, "modulate:a", 1, 0,
			GLOW_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	$PressStartSFX.play()
	camera.add_shake(1)
	
	$PressStartTimer.start()


func change_screen():
	Transition.transition_in()
	set_process_input(false)
	yield(Transition, "finished")
	get_tree().change_scene_to(ModeSelect)


func _on_PressStartTimer_timeout():
	$PressStart/AnimationPlayer.play("show")
