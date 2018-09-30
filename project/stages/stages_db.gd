extends Node

const STAGES = [
preload('res://stages/stage1.tscn'),
preload('res://stages/stage2.tscn'),
preload('res://stages/stage3.tscn'),
preload('res://stages/stage4.tscn'),
preload('res://stages/stage5.tscn'),
preload('res://stages/stage6.tscn'),
preload('res://stages/stage7.tscn'),
preload('res://stages/stage8.tscn'),
preload('res://stages/stage9.tscn'),
preload('res://stages/stage10.tscn')
]

func get_random_stage():
	return STAGES[1 + (randi() % STAGES.size() - 1)]

func get_first_stage():
	return STAGES[0]
