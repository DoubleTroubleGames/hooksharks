extends Control

enum { MASTER, SFX, BGM }

var resolutions = ["1920x1080", "1440x900", "1366x768", "1280x800"]

onready var fullscreen_button = $Resolution/Box/Fullscreen
onready var screen_size_button = $Resolution/Box/ScreenSize
onready var sound_master = $Sound/Float/VScrollBar/MasterVolume/MasterVolume
onready var sound_sfx = $Sound/Float/VScrollBar/SFXVolume/SFXVolume
onready var sound_bgm = $Sound/Float/VScrollBar/BGMVolume/BGMVolume


func _ready():
	var native_size = OS.get_screen_size()
	native_size = str(native_size.x, "x", native_size.y)
	fullscreen_button.pressed = OS.window_fullscreen
	sound_master.value = 100 * db2linear(AudioServer.get_bus_volume_db(MASTER))
	sound_sfx.value = 100 * db2linear(AudioServer.get_bus_volume_db(SFX))
	sound_bgm.value = 100 * db2linear(AudioServer.get_bus_volume_db(BGM))
	if not native_size in resolutions:
		resolutions.append(native_size)
	for res in resolutions:
		screen_size_button.add_item(res)
	screen_size_button.selected = resolutions.find(native_size)

	$Resolution/Box/Fullscreen.grab_focus()


func _on_transition_in() -> void:
	set_process_input(false)


func _input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		# Wait to update button until FullscreenToggle is done
		yield(get_tree(), "idle_frame")
		fullscreen_button.pressed = OS.window_fullscreen


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if button_pressed:
		var native_res = OS.get_screen_size()
		screen_size_button.selected = resolutions.find(str(native_res.x, "x", native_res.y))


func _on_ScreenSize_item_selected(id):
	var new_res = screen_size_button.get_item_text(id)
	OS.window_size = Vector2(int(new_res.split("x")[0]), int(new_res.split("x")[1]))


func _on_MasterVolume_value_changed(value):
	var volume = float(value) / 100.0
	AudioServer.set_bus_volume_db(MASTER, linear2db(volume))


func _on_SFXVolume_value_changed(value):
	var volume = float(value) / 100.0
	AudioServer.set_bus_volume_db(SFX, linear2db(volume))


func _on_BGMVolume_value_changed(value):
	var volume = float(value) / 100.0
	AudioServer.set_bus_volume_db(BGM, linear2db(volume))


func _on_BackIndicator_completed() -> void:
	Transition.transition_to("ModeSelect")
