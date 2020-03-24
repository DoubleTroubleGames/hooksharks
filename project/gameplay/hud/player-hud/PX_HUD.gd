extends Control

onready var dive_bar = $DiveBar
onready var indicator = $Indicator
onready var indicator_label = $Indicator/Label
onready var messages = $Messages
onready var trail_label = $TimerLabels/TrailLabel
onready var dive_label = $TimerLabels/DiveLabel
onready var dive_timer = $DiveTimer
onready var trail_timer = $TrailTimer

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


func _process(delta):
	if trail_label.visible:
		trail_label.set_text("%.1f" % trail_timer.time_left)
	if dive_label.visible:
		dive_label.set_text("%.1f" % dive_timer.time_left)


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

func _on_dive_hide():
	dive_bar_showing = false
	dive_bar.modulate.a	= 0


func _on_fire_trail_started(powerup):
	trail_label.text = str(trail_timer.wait_time)
	trail_label.show()
	trail_timer.start()
	
	if powerup:
		trail_timer.connect("timeout", powerup, "deactivate")


func _on_infinite_dive_started(powerup):
	dive_label.text = str(dive_timer.wait_time)
	dive_bar_showing = false
	dive_label.show()
	dive_timer.start()
	
	if powerup:
		dive_timer.connect("timeout", powerup, "deactivate")


func _on_TrailTimer_timeout():
	trail_label.hide()


func _on_DiveTimer_timeout():
	dive_bar_showing = true
	dive_label.hide()
