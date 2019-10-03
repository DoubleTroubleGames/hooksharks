extends CanvasLayer

onready var label_dict = {1 : $P1Label, 2 : $P2Label, 3 : $P3Label, 4 : $P4Label}

const LERP_FACTOR = .2
const OFFSET = Vector2(-20, -110)

var player_dict

func set_players(player_dict):
	self.player_dict = player_dict
	for p in player_dict:
		if player_dict[p] == null:
			label_dict[p].hide()
		else:
			label_dict[p].modulate = RoundManager.CHAR_COLOR[RoundManager.character_map[player_dict[p].id]]
			label_dict[p].modulate.a = 0
			label_dict[p].is_showing = false


func _physics_process(delta):
	for p in player_dict:
		if player_dict[p] and is_instance_valid(player_dict[p]):
			label_dict[p].rect_position = player_dict[p].global_position + OFFSET
			if label_dict[p].is_showing:
				label_dict[p].modulate.a = lerp(label_dict[p].modulate.a, 1, LERP_FACTOR)
			else:
				label_dict[p].modulate.a = lerp(label_dict[p].modulate.a, 0, LERP_FACTOR)

func show_all():
	for i in range(1,5):
		label_dict[i].is_showing = true

func hide_all():
	for i in range(1,5):
		label_dict[i].is_showing = false

func show_label(player_number):
	label_dict[player_number].is_showing = true


func hide_label(player_number):
	label_dict[player_number].is_showing = false
