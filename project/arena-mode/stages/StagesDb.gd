extends Node

const STAGE_NUM = 10

func get_random_stage():
	var base_dir = self.get_script().get_path().get_base_dir()
	return load(str(base_dir, '/Stage', (randi() % STAGE_NUM - 1) + 2, '.tscn'))

func get_first_stage():
	var base_dir = self.get_script().get_path().get_base_dir()
	return load(str(base_dir, '/Stage1.tscn'))
