extends Node2D

const PROCESS = 2

var players

func _ready():
	players = get_node('../Players').get_children()

func remove_player(player, is_player_collision):
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
		if not is_player_collision:
			var winner_id = get_winner_id(winner)
			Global.scores[winner_id] += 1
			Global.winner = winner_id
		else:
			Global.winner = -1
		winner.set_physics_process(false)
		winner.set_process_input(false)

func get_winner_id(winner):
	var Main = winner.get_parent().get_parent()
	
	if not Main.use_keyboard:
		return winner.id 
	if winner.id == -1:
		return Main.keyboard_id
	if winner.id >= Main.keyboard_id:
		return winner.id + 1
	
	return winner.id
