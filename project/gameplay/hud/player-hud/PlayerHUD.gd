extends CanvasLayer

onready var label_dict = {1 : $P1/Label, 2 : $P2/Label, 3 : $P3/Label, 4 : $P4/Label}
onready var hud = [null, $P1, $P2, $P3, $P4]

var player_dict
var camera

func set_players(player_dict, camera):
	self.camera = camera
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
			hud[p].rect_position = player_dict[p].get_global_transform_with_canvas().origin

func show_all():
	for i in range(4):
		label_dict[i+1].is_showing = true

func hide_all():
	for i in range(4):
		label_dict[i+1].is_showing = false

func show_label(player_number):
	label_dict[player_number].is_showing = true


func hide_label(player_number):
	label_dict[player_number].is_showing = false
