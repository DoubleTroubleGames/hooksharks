extends Node

const STAGES = [
preload('res://stages/Stage1.tscn'),
preload('res://stages/Stage2.tscn'),
preload('res://stages/Stage3.tscn'),
preload('res://stages/Stage4.tscn'),
preload('res://stages/Stage5.tscn'),
#preload('res://stages/Stage6.tscn'),
preload('res://stages/Stage7.tscn'),
preload('res://stages/Stage8.tscn'),
preload('res://stages/Stage9.tscn'),
preload('res://stages/Stage10.tscn')
]

func get_random_stage():
	return STAGES[1 + (randi() % (STAGES.size() - 1))]

func get_first_stage():
	return STAGES[0]
