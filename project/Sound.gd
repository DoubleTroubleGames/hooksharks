extends Node

onready var game_bgm = $GameBGM
onready var menu_bgm = $MenuBGM
onready var tween = $Tween

func _ready():
	$MenuBGM.play()

func play_ambience():
	$Ambience.play()

func stop_ambience():
	$Ambience.stop()

func fade_out(track, duration = 1.0):
	tween.interpolate_property(track, "volume_db", null, -80, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_completed")
	track.stop()
	track.volume_db = 0
