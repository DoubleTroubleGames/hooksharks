extends CanvasLayer

onready var hud = [null, $P1, $P2, $P3, $P4]

var player_dict
var camera

func set_players(player_dict, camera):
	self.camera = camera
	self.player_dict = player_dict
	for p in player_dict:
		if player_dict[p]:
			player_dict[p].connect("message_received", hud[p], "add_message")
			player_dict[p].connect("dive_value_changed", hud[p], "on_dive_value_changed")
			player_dict[p].connect("dive_texture_changed", hud[p], "on_dive_texture_changed")
			player_dict[p].connect("dive_visibility_changed", hud[p], "on_dive_visibility_changed")
			hud[p].set_player_color(RoundManager.CHAR_COLOR[RoundManager.character_map[player_dict[p].id]])
		else:
			hud[p].hide()


func _physics_process(delta):
	for p in player_dict:
		if player_dict[p] and is_instance_valid(player_dict[p]):
			hud[p].rect_position = player_dict[p].get_global_transform_with_canvas().origin


func show_all():
	for i in range(4):
		hud[i+1].indicator_showing = true


func hide_all():
	for i in range(4):
		hud[i+1].indicator_showing = false


func show_indicator(player_number):
	hud[player_number].indicator_showing = true


func hide_label(player_number):
	hud[player_number].indicator_showing = false
