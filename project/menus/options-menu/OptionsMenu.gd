extends Control

onready var bar = $BackIndicator/Progress
onready var anim_player = $BackIndicator/AnimationPlayer
onready var FullscreenButton = $Resolution/Box/Fullscreen
onready var ScreenSizeButton = $Resolution/Box/ScreenSize
onready var SoundMaster = $Sound/Float/VScrollBar/MasterVolume/MasterVolume
onready var SoundSFX = $Sound/Float/VScrollBar/SFXVolume/SFXVolume
onready var SoundBGM = $Sound/Float/VScrollBar/BGMVolume/BGMVolume

var resolutions = ['1920x1080', '1440x900', '1366x768', '1280x800']
var back_indicator_up_speed = 100
var back_indicator_down_speed = 150


func _ready():
	var native_size = OS.get_screen_size()
	native_size = str(native_size.x, 'x', native_size.y)
	
	Transition.transition_out()
	yield(Transition, "finished")
	
	FullscreenButton.pressed = OS.window_fullscreen
	SoundMaster.value = 100 * db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	SoundSFX.value = 100 * db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	SoundBGM.value = 100 * db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	if not native_size in resolutions:
		resolutions.append(native_size)
	for res in resolutions:
		ScreenSizeButton.add_item(res)
	ScreenSizeButton.selected = resolutions.find(native_size)
	
	$Resolution/Box/Fullscreen.grab_focus()


func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		bar.value = min(100, bar.value + back_indicator_up_speed*delta)
	else:
		bar.value = max(0, bar.value - back_indicator_down_speed * delta)
	
	if bar.value >= 100:
		Transition.transition_in()
		yield(Transition, "finished")
		get_tree().change_scene_to(load("res://menus/mode-select/ModeSelect.tscn"))
	elif bar.value > 0:
		if anim_player.assigned_animation != "show":
			anim_player.play("show")
	elif anim_player.assigned_animation == "show":
			anim_player.play("hide")


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if button_pressed:
		var native_res = OS.get_screen_size()
		ScreenSizeButton.selected = resolutions.find(str(native_res.x, 'x', native_res.y))

func _on_ScreenSize_item_selected(ID):
	var new_res = ScreenSizeButton.get_item_text(ID)
	OS.window_size = Vector2(int(new_res.split('x')[0]), int(new_res.split('x')[1]))

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
