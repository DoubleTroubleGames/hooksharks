extends Node2D

signal completed

const CANCEL_ACTION = "ui_cancel"
const SHOW_ANIMATION = "show"

export var text := "Hold BACK to leave" setget set_text
export var up_time_sec := 1.0
export var down_time_sec := 0.67
export var disable_on_complete := true

var _is_ready := false
var _started_by: String

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var bar: TextureProgress = $TextureProgress
onready var label: Label = $Label
onready var tween: Tween = $"%Tween"


func _ready() -> void:
	_is_ready = true
	label.text = text


func _input(event: InputEvent) -> void:
	if not event.is_action_released(CANCEL_ACTION):
		return

	if RoundManager.get_device_name_from(event) == _started_by:
		stop()
		set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(CANCEL_ACTION):
		set_process_unhandled_input(false)
		_started_by = RoundManager.get_device_name_from(event)
		start()


func set_text(value: String) -> void:
	text = value
	if _is_ready:
		label.text = text


func start() -> void:
	if bar.ratio == 1.0:
		return

	tween_to(bar.max_value, up_time_sec * (1.0 - bar.ratio))
	if anim_player.assigned_animation != SHOW_ANIMATION:
		anim_player.play(SHOW_ANIMATION)


func stop() -> void:
	tween_to(bar.min_value, down_time_sec * bar.ratio)


func tween_to(value: float, time_sec: float) -> void:
	tween.remove_all()
	tween.interpolate_property(bar, "value", bar.value, value, time_sec, Tween.TRANS_LINEAR)
	tween.start()


func _on_Tween_tween_all_completed() -> void:
	if bar.ratio == 0.0:
		anim_player.play("hide")

	elif bar.ratio == 1.0:
		emit_signal("completed")
		set_process_input(not disable_on_complete)
		set_process_unhandled_input(not disable_on_complete)
