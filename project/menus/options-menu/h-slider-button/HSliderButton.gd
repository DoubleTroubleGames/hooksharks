extends BaseButton

signal value_changed(value)

export var value: float setget set_value

var slider_active: bool setget set_slider_active

var _is_ready := false

onready var container: MarginContainer = $MarginContainer
onready var slider: Slider = $"%HSlider"


func _init() -> void:
	connect("toggled", self, "_on_toggled")


func _ready() -> void:
	_is_ready = true
	rect_min_size = container.rect_size
	slider.set_block_signals(true)
	slider.value = value
	slider.set_block_signals(false)


func set_slider_active(new_value: bool) -> void:
	slider_active = new_value
	if slider_active:
		slider.focus_mode = Control.FOCUS_ALL
		slider.mouse_filter = Control.MOUSE_FILTER_PASS
		slider.grab_focus()

	else:
		slider.focus_mode = Control.FOCUS_NONE
		slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pressed = false
		grab_focus()


func set_value(new_value: float) -> void:
	value = new_value
	if _is_ready:
		slider.value = new_value


func _on_HSlider_focus_exited() -> void:
	if slider_active:
		set_slider_active(false)


func _on_HSlider_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		slider.accept_event()
		set_slider_active(false)


func _on_HSlider_value_changed(new_value: float) -> void:
	value = new_value
	emit_signal("value_changed", new_value)


func _on_toggled(button_pressed: bool) -> void:
	if button_pressed:
		set_slider_active(true)
