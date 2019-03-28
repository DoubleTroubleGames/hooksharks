extends Node2D

onready var Stage = get_parent()

const WIDTH = 10

export (int)var total_checkpoint_number = 0
export (int)var total_laps = 1

var line_polygon
var top_pulling = false
var bot_pulling = false
var line_tex = preload("res://assets/line.png")


func _ready():
	update_line_polygon()
	rotate_line()
	add_line_sprites()
	$LineArea/CollisionPolygon2D.polygon = line_polygon
	set_physics_process(false)


func _draw():
	var color_array = [Color(1, 1, 1), Color(0, 0, 0), Color(1, 1, 1), Color(0, 0, 0)]
	draw_polygon(line_polygon, color_array)


func _physics_process(delta):
	update_line_polygon()
	update()
	rotate_line()


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
	$LineSprites.rotation = angle
	$LineSprites.position = $PullableObjectBot.position


func add_line_sprites():
	var distance = abs($PullableObjectTop.position.distance_to($PullableObjectBot.position))
	var pos = 57.5
	
	while distance > 0:
		var sprite = Sprite.new()
		
		sprite.texture = line_tex
		sprite.position = Vector2(pos, 0)
		if distance < 115:
			var rect = Rect2(Vector2(0, 0), Vector2(distance, 115))
			sprite.region_enabled = true
			sprite.region_rect = rect
			sprite.position.x += 115 - distance
		$LineSprites.add_child(sprite)
		
		pos += 115
		distance -= 115


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
				var players = get_parent().get_parent().players

				$LineArea/CollisionPolygon2D.disabled = true
				for child in players:
					if child != winner:
						child.call_deferred("die")


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
