extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Fullscreen.pressed = OS.window_fullscreen


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_MasterVolume_value_changed(value):
	var volume = float(value)/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(volume))

func _on_SFXVolume_value_changed(value):
	var volume = float(value)/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(volume))

func _on_BGMVolume_value_changed(value):
	var volume = float(value)/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear2db(volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear2db(volume * 0.9))
