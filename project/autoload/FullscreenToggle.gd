extends Node


func _ready():
	# Allow toggling fullscreen when round is paused
	pause_mode = Node.PAUSE_MODE_PROCESS


func _input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
