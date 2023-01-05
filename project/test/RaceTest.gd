extends "res://gameplay/race-mode/Race.gd"


enum MovementTypes {DIRECT, TANK}

export (PackedScene)var TestStage


func test_setup():
	# runs on _ready() on Game.gd
	RoundManager.players_total = 2
	RoundManager.device_map.append("keyboard")
	RoundManager.device_map.append("test_keyboard")
	RoundManager.character_map.append("jackie")
	RoundManager.character_map.append("drill")
	RoundManager.movement_type_map.append(MovementTypes.TANK)
	RoundManager.movement_type_map.append(MovementTypes.TANK)
	RoundManager.reset_round()


func get_first_stage():
	return TestStage


func get_random_stage():
	return TestStage
