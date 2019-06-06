extends Node2D

onready var stage = get_parent()

const WIDTH = 10
const LINE_SPRITE_SIZE = 115

export (int)var total_checkpoint_number = 0
export (int)var total_laps = 1

var line_polygon
var top_pulling = false
var bot_pulling = false
var line_tex = preload("res://assets/images/elements/line.png")


func _ready():
	update_line_polygon()
	rotate_line()
	adjust_line_size()
	set_physics_process(false)

func get_laps():
	return total_laps

func _physics_process(delta):
	update_line_polygon()
	rotate_line()
	adjust_line_size()


func update_line_polygon():
	var PullTop_pos = $PullableObjectTop.get_position()
	var PullBot_pos = $PullableObjectBot.get_position()
	line_polygon = PoolVector2Array([Vector2(PullTop_pos.x - WIDTH, PullTop_pos.y + WIDTH),
			Vector2(PullTop_pos.x + WIDTH, PullTop_pos.y - WIDTH),
			Vector2(PullBot_pos.x + WIDTH, PullBot_pos.y - WIDTH),
			Vector2(PullBot_pos.x - WIDTH, PullBot_pos.y + WIDTH)])
	$LineArea/CollisionPolygon2D.polygon = line_polygon


func rotate_line():
	var angle = $PullableObjectTop.position.angle_to_point($PullableObjectBot.position)
	$PullableObjectTop.rotation = angle
	$PullableObjectBot.rotation = angle


func adjust_line_size():
	var distance = abs($PullableObjectTop.position.distance_to($PullableObjectBot.position))
	$PullableObjectBot/Line.rect_size.x = distance


func _on_LineArea_area_entered(area):
	# This area only monitors PLAYER_ABOVE.
	var player = area.get_parent().get_parent()
	var checkpoint_num = stage.get_player_checkpoint(player)
	
	if player.invincible:
		return
	if checkpoint_num == total_checkpoint_number:
		stage.increase_player_lap(player)
		stage.reset_player_checkpoint(player)
		var lap_num = stage.get_player_lap(player)
		
		if lap_num >= total_laps:
			if randf() < .01:
				player.add_label("A winner is you!")
			else:
				player.add_label("Winner!")
		else:
			player.add_label("Lap %s/%s" % [lap_num, total_laps])
		
		if lap_num >= total_laps:
			var winner = player
			var players = get_parent().get_parent().players
			
			$LineArea/CollisionPolygon2D.set_deferred("disabled", true)
			for child in players:
				if child != winner:
					child.respawn = false
					child.call_deferred("die")
	else:
		player.add_label("Wrong Way")


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
