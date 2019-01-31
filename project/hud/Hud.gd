extends Control

signal finished

const WINNER_POS = [Vector2(80, 200), Vector2(958, 200)]
const MENU_POS = Vector2(292, 550)

onready var left_markers = [$Round/BallsLeft/X1, $Round/BallsLeft/X2,
		$Round/BallsLeft/X3]
onready var right_markers = [$Round/BallsRight/X1, $Round/BallsRight/X2,
		$Round/BallsRight/X3]
onready var winner = $Round/Winner
onready var tween = $Tween
onready var display_timer = $DisplayTimer
onready var camera = get_node('../Camera2D')

var round_texture = [
		preload("res://hud/round_screen/ui_01.png"),
		preload("res://hud/round_screen/ui_02.png"),
		preload("res://hud/round_screen/ui_03.png"),
		preload("res://hud/round_screen/ui_04.png"),
		preload("res://hud/round_screen/ui_05.png")]

func _ready():
	modulate = Color(1, 1, 1, 0)
	
	$Round/Number.texture = round_texture[Global.round_number - 1]
	
	randomize()
	for x in left_markers:
		x.rotation_degrees = rand_range(-20, 20)
	for x in right_markers:
		x.rotation_degrees = rand_range(-20, 20)
	
	for i in range(Global.scores[0]):
		left_markers[i].visible = true
	for i in range(Global.scores[1]):
		right_markers[i].visible = true
	

func show_round():
	if Global.winner == -1:
		$Round/Draw.visible = true
		$Round/Text.visible = false
		$Round/Number.visible = false
	
	# Fade in
	get_node('../Mirage').visible = false
	get_node('../Blur').visible = true
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0),
		Color(1, 1, 1, 1), .5, Tween.TRANS_LINEAR, Tween.EASE_IN, .1)
	tween.start()
	yield(tween, "tween_completed")
	
	# Marker animation 
	var marker = null
	if Global.winner == 0:
		marker = left_markers[Global.scores[0] - 1]
	elif Global.winner == 1:
		marker = right_markers[Global.scores[1] - 1]
	
	BGM.get_node('Score').play()
	
	if marker:
		marker.visible = true
		marker.scale = Vector2(2, 2)
		marker.modulate = Color(1, 1, 1, 0)
		tween.interpolate_property(marker, "scale", marker.scale, Vector2(1, 1),
			.5, Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.interpolate_property(marker, "modulate", marker.modulate,
			Color(1, 1, 1, 1), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		var timer = Timer.new()
		timer.wait_time = .15
		self.add_child(timer)
		timer.start()
		yield(timer, 'timeout')
		timer.queue_free()
		camera.add_shake(.3)
		yield(tween, "tween_completed")
	
	if Global.scores[0] < 3 and Global.scores[1] < 3:
		display_timer.start()
		yield(display_timer, "timeout")
		emit_signal("finished")
		return
	
	# Winner label animation
	winner.rect_position = WINNER_POS[Global.winner] - Vector2(0, 400)
	winner.visible = true
	tween.interpolate_property(winner, "rect_position", winner.rect_position,
		WINNER_POS[Global.winner],
		.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	# Menu animation
	tween.interpolate_property($Round/Restart, "rect_position", $Round/Restart.rect_position,
		MENU_POS, .5, Tween.TRANS_BACK, Tween.EASE_OUT, .5)
	tween.interpolate_property($Round/Quit, "rect_position", $Round/Quit.rect_position,
		MENU_POS + Vector2(690-292, 0), .5, Tween.TRANS_BACK, Tween.EASE_OUT, .5)
	tween.start()
	yield(tween, "tween_completed")
	$Round/Restart.disabled = false
	$Round/Restart.grab_focus()
	$Round/Quit.disabled = false
	
	Global.scores = [0, 0]
	Global.round_number = 1

func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Quit_pressed():
	get_tree().change_scene("res://main-menu/MainMenu.tscn")
