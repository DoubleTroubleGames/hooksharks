extends Node2D

const PROCESS = 2

var players

func _ready():
	players = get_node('../Players').get_children()

func remove_player(player, player_collision):
	players.erase(player)
	if players.size() == 1:
		var timer = Timer.new()
		var winner = players[0]
		timer.wait_time = 2
		self.add_child(timer)
		timer.connect('timeout', self, 'reload_map', [timer])
		timer.pause_mode = PROCESS
		timer.start()
		if not player_collision:
			get_node('/root/global').scores[winner.id] += 1
		winner.set_physics_process(false)

func reload_map(timer):
	timer.queue_free()
	get_tree().reload_current_scene()
