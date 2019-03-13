extends Node2D

onready var Stage = get_parent()

const WIDTH = 10

export (int)var total_checkpoint_number = 0
export (int)var total_laps = 1

var line_polygon
var top_pulling = false
var bot_pulling = false


func _ready():
	update_line_polygon()
	$LineArea/CollisionPolygon2D.polygon = line_polygon


func _draw():
	var color_array = [Color(1, 1, 1), Color(0, 0, 0), Color(1, 1, 1), Color(0, 0, 0)]
	draw_polygon(line_polygon, color_array)

func _physics_process(delta):
	update_line_polygon()
	update()
	$LineArea/CollisionPolygon2D.polygon = line_polygon


func update_line_polygon():
	var PullTop_pos = $PullableObjectTop.get_position()
	var PullBot_pos = $PullableObjectBot.get_position()
	line_polygon = PoolVector2Array([Vector2(PullTop_pos.x - WIDTH, PullTop_pos.y + WIDTH),
								   Vector2(PullTop_pos.x + WIDTH, PullTop_pos.y - WIDTH),
								   Vector2(PullBot_pos.x + WIDTH, PullBot_pos.y - WIDTH),
								   Vector2(PullBot_pos.x - WIDTH, PullBot_pos.y + WIDTH)])


func _on_LineArea_area_entered(area):
	if area.get_parent().is_in_group('player'):
		var Player = area.get_parent()
		var checkpoint_num = Stage.get_player_checkpoint(Player)
		if checkpoint_num == total_checkpoint_number:
			Stage.inscrease_player_lap(Player)
			Stage.reset_player_checkpoint(Player)

			var lap_num = Stage.get_player_lap(Player)
			if lap_num >= total_laps:
				var winner = Player
				var players = winner.get_parent()

				$LineArea/CollisionPolygon2D.disabled = true
				for child in players.get_children():
					if child.is_in_group('player') and child != winner:
						child.die()


func _on_PullableObjectTop_hooked():
	set_physics_process(true)
	top_pulling = true


func _on_PullableObjectBot_hooked():
	set_physics_process(true)
	bot_pulling = true


func _on_PullableObjectTop_unhooked():
	top_pulling = false
	if not top_pulling and not bot_pulling:
		set_physics_process(false)


func _on_PullableObjectBot_unhooked():
	bot_pulling = false
	if not top_pulling and not bot_pulling:
		set_physics_process(false)
