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
		timer.wait_time = 1
		self.add_child(timer)
		timer.connect('timeout', get_parent(), 'show_round')
		timer.one_shot = true
		timer.pause_mode = PROCESS
		timer.start()
		if not player_collision:
			global.scores[winner.id] += 1
			global.winner = winner.id
		else:
			global.winner = -1
		winner.set_physics_process(false)
		winner.set_process_input(false)
