extends Control

onready var dive_bar = $DiveBar
onready var indicator = $Indicator
onready var indicator_label = $Indicator/Label
onready var messages = $Messages

const MESSAGE_LABEL = preload("res://gameplay/hud/player-hud/MessageLabel.tscn")
const LERP_FACTOR = .2

export(String) var label_string = "PX"

var dive_bar_showing = false
var indicator_showing = false
var message_stack = []


func _ready():
	dive_bar.modulate.a = 0
	indicator_label.text = label_string


func _physics_process(delta):
	if indicator_showing:
		indicator.modulate.a = lerp(indicator.modulate.a, 1, LERP_FACTOR)
	else:
		indicator.modulate.a = lerp(indicator.modulate.a, 0, LERP_FACTOR)
	
	if dive_bar_showing:
		dive_bar.modulate.a = lerp(dive_bar.modulate.a, 1, LERP_FACTOR)
	else:
		dive_bar.modulate.a = lerp(dive_bar.modulate.a, 0, LERP_FACTOR)


func set_player_color(c):
	indicator.modulate = c
	indicator.modulate.a = 0


func add_message(text, color):
	var message = MESSAGE_LABEL.instance()
	message.text = text
	
	if message_stack.empty():
		display(message)
	
	message_stack.append(message)


func display(message):
	message.connect("display_ended", self, "_on_display_ended")
	messages.add_child(message)


func _on_display_ended():
	message_stack.pop_front()
	
	if not message_stack.empty():
		display(message_stack.front())


func _on_dive_value_changed(value):
	dive_bar.value = value


func _on_dive_texture_changed(texture):
	dive_bar.texture_progress = texture


func _on_dive_visibility_changed(visibility):
	dive_bar_showing = visibility
