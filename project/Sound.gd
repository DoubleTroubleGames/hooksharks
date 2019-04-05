extends Node

func _ready():
	$BGM.play()

func play_ambience():
	$Ambience.play()

func stop_ambience():
	$Ambience.stop()