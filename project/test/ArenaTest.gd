extends "res://gameplay/arena-mode/Arena.gd"

export (PackedScene)var TestStage


func test_setup():
	# runs on _ready() on Game.gd
	RoundManager.players_total = 2
	RoundManager.device_map.append("keyboard")
	RoundManager.device_map.append("test_keyboard")
	RoundManager.character_map.append("pirate")
	RoundManager.character_map.append("drill")
	RoundManager.reset_round()


func get_first_stage():
	return TestStage


func get_random_stage():
	return TestStage
