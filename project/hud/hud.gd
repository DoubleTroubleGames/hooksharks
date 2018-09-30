extends Control

const WINNER_POS = [Vector2(80, 200), Vector2(958, 200)]

signal finished

onready var left_markers = [$Round/BallsLeft/X1, $Round/BallsLeft/X2, $Round/BallsLeft/X3]
onready var right_markers = [$Round/BallsRight/X1, $Round/BallsRight/X2, $Round/BallsRight/X3]
onready var winner = $Round/Winner
onready var menu = $Round/Menu
onready var tween = $Tween
onready var display_timer = $DisplayTimer

var round_texture = [preload("res://hud/round_screen/UI_01.png"),
					preload("res://hud/round_screen/UI_02.png"),
					preload("res://hud/round_screen/UI_03.png"),
					preload("res://hud/round_screen/UI_04.png"),
					preload("res://hud/round_screen/UI_05.png")]

func _ready():
	$Round/Number.texture = round_texture[global.round_number - 1]
	
	randomize()
	for x in left_markers:
		x.rotation_degrees = rand_range(-20, 20)
	for x in right_markers:
		x.rotation_degrees = rand_range(-20, 20)
	
	for i in range(global.scores[0]):
		left_markers[i].visible = true
	for i in range(global.scores[1]):
		right_markers[i].visible = true

func show_round():
	# Fade in
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1),
		.5, Tween.TRANS_LINEAR, Tween.EASE_IN, .1)
	tween.start()
	yield(tween, "tween_completed")
	
	# Marker animation 
	var marker = null
	if global.winner == 0:
		marker = left_markers[global.scores[0] - 1]
	elif global.winner == 1:
		marker = right_markers[global.scores[1] - 1]
	
	bgm.get_node('Score').play()
	
	if marker:
		marker.visible = true
		marker.scale = Vector2(2, 2)
		marker.modulate = Color(1, 1, 1, 0)
		tween.interpolate_property(marker, "scale", marker.scale, Vector2(1, 1), .5,
			Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.interpolate_property(marker, "modulate", marker.modulate, Color(1, 1, 1, 1), .5,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
	
	if global.scores[0] < 3 and global.scores[1] < 3:
		display_timer.start()
		yield(display_timer, "timeout")
		emit_signal("finished")
		return
	
	# Winner label animation
	winner.rect_position = WINNER_POS[global.winner] - Vector2(0, 400)
	winner.visible = true
	tween.interpolate_property(winner, "rect_position", winner.rect_position, WINNER_POS[global.winner],
		.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	# Menu animation
	tween.interpolate_property(menu, "rect_position", menu.rect_position, Vector2(menu.rect_position.x, 590),
		.5, Tween.TRANS_BACK, Tween.EASE_OUT, .5)
	tween.start()
	yield(tween, "tween_completed")
	$Round/Menu/Restart.disabled = false
	$Round/Menu/Restart.grab_focus()
	$Round/Menu/Quit.disabled = false
	
	global.scores = [0, 0]
	global.round_number = 1


func _on_Restart_pressed():
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	get_tree().change_scene("res://main_menu/main_menu.tscn")
