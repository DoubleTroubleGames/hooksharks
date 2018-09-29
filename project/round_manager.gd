extends Node2D

const PROCESS = 2

var players

func _ready():
	players = get_node('../Players').get_children()

func remove_player(player):
	players.erase(player)
	if players.size() == 1:
		var timer = Timer.new()
		timer.wait_time = 2
		self.add_child(timer)
		timer.connect('timeout', self, 'reload_map', [timer])
		timer.pause_mode = PROCESS
		timer.start()
		get_node('/root/global').scores[player.id] += 1
		get_tree().paused = true

func reload_map(timer):
	timer.queue_free()
	get_tree().reload_current_scene()
