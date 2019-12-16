extends Node

onready var battle_bgm = $BattleBGM
onready var menu_bgm = $MenuBGM
onready var tween = $Tween

const BATTLE_MUSIC = [preload("res://assets/sound/bgm/battle_1.ogg"),
		preload("res://assets/sound/bgm/battle_2.ogg"),
		preload("res://assets/sound/bgm/battle_3.ogg")]

func _ready():
	randomize()


func play_battle_bgm():
	randomize_battle_bgm()
	battle_bgm.play()


func play_ambience():
	$Ambience.play()


func stop_ambience():
	$Ambience.stop()


func on_pause():
	battle_bgm.bus = "BGM_Paused"


func on_unpause():
	battle_bgm.bus = "BGM"


func fade_out(track, next_track = null, duration = 1.0):
	tween.interpolate_property(track, "volume_db", null, -80, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_completed")
	track.stop()
	track.volume_db = 0
	on_unpause()
	
	if next_track:
		next_track.play()


func randomize_battle_bgm():
	battle_bgm.stream = BATTLE_MUSIC[randi() % BATTLE_MUSIC.size()]
