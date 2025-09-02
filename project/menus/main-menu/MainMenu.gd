extends Control

const TITLE_OFFSET = Vector2(5000, 0)
const TITLE_DELAY = .5
const GLOW_DURATION = 1

var title_shown = false

onready var camera = $Camera2D
onready var title = $Title
onready var tween = $Tween
onready var title_pos = title.rect_position


func _ready():
	title.rect_position = title.rect_position - TITLE_OFFSET.rotated(deg2rad(title.rect_rotation))

	if Transition.is_black_screen:
		yield(Transition, "finished")

	tween.interpolate_property(
		title,
		"rect_position",
		null,
		title_pos,
		1.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		TITLE_DELAY
	)
	tween.start()
	$TitleAnticipationSFX.play()

	yield(tween, "tween_completed")
	show_title()

	$PressStartTimer.start()


func _input(event):
	if event.is_action_pressed("ui_start"):
		if not title_shown:
			show_title()
		else:
			change_screen()


func show_title():
	if title_shown:
		return

	title_shown = true

	if not Sound.menu_bgm.playing:
		Sound.menu_bgm.play()

	tween.remove_all()
	title.rect_position = title_pos
	$TitleAnticipationSFX.stop()

	$TitleAppearSFX.play()

	tween.interpolate_property(
		$CanvasLayer/ScreenGlow,
		"modulate:a",
		1,
		0,
		GLOW_DURATION,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	tween.start()
	camera.add_shake(1)

	$PressStartTimer.start()


func change_screen():
	$StartPressSFX.play()
	Transition.transition_to("ModeSelect")


func _on_BackIndicator_completed() -> void:
	get_tree().quit()


func _on_transition_in() -> void:
	set_process_input(false)


func _on_PressStartTimer_timeout():
	$PressStartShowSFX.play()
	$PressStart/AnimationPlayer.play("show")
