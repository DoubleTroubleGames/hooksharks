extends Control

var resolutions = ['1920x1080', '1440x900', '1366x768', '1280x800']


func _ready():
	var native_size = OS.get_screen_size()
	native_size = str(native_size.x, 'x', native_size.y)
	
	$Resolution/Fullscreen.pressed = OS.window_fullscreen
	if not native_size in resolutions:
		resolutions.append(native_size)
	for res in resolutions:
		$Resolution/ScreenSize.add_item(res)
	$Resolution/ScreenSize.selected = resolutions.find(native_size)


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	if button_pressed:
		var native_res = OS.get_screen_size()
		$Resolution/ScreenSize.selected = resolutions.find(str(native_res.x, 'x', native_res.y))

func _on_ScreenSize_item_selected(ID):
	var new_res = $Resolution/ScreenSize.get_item_text(ID)
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
