extends Node

const STAGES = [
		preload('res://race-mode/stages/Stage1.tscn'),
		preload('res://race-mode/stages/Stage2.tscn')]

func get_random_stage():
	return STAGES[1 + (randi() % (STAGES.size() - 1))]

func get_first_stage():
	return STAGES[0]
