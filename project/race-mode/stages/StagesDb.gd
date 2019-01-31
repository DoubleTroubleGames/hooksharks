extends Node

const STAGES = [
		preload('res://race-mode/stages/Stage1.tscn'),
		preload('res://race-mode/stages/Stage2.tscn'),
		preload('res://race-mode/stages/Stage3.tscn'),
		preload('res://race-mode/stages/Stage4.tscn'),
		preload('res://race-mode/stages/Stage5.tscn'),
		#preload('res://race-mode/stages/Stage6.tscn'),
		preload('res://race-mode/stages/Stage7.tscn'),
		preload('res://race-mode/stages/Stage8.tscn'),
		preload('res://race-mode/stages/Stage9.tscn'),
		preload('res://race-mode/stages/Stage10.tscn')]

func get_random_stage():
	return STAGES[1 + (randi() % (STAGES.size() - 1))]

func get_first_stage():
	return STAGES[0]
