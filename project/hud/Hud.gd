extends CanvasLayer

signal finished

onready var left_markers = $Background/Round/BallsLeft.get_children()
onready var right_markers = $Background/Round/BallsRight.get_children()
onready var number = $Background/Round/Number
onready var winner = $Background/Round/Winner
onready var tween = $Tween
onready var display_timer = $DisplayTimer

const WINNER_POS = [Vector2(80, 200), Vector2(958, 200)]
const MENU_POS = Vector2(292, 550)

const ROUND_TEXTURES = [
		preload("res://hud/round_screen/ui_01.png"),
		preload("res://hud/round_screen/ui_02.png"),
		preload("res://hud/round_screen/ui_03.png"),
		preload("res://hud/round_screen/ui_04.png"),
		preload("res://hud/round_screen/ui_05.png")]

func _ready():
	$Background.modulate = Color(1, 1, 1, 0)
	
	number.texture = round_texture[RoundManager.round_number - 1]
	
	randomize()
	for x in left_markers:
		x.rotation_degrees = rand_range(-20, 20)
	for x in right_markers:
		x.rotation_degrees = rand_range(-20, 20)
	
	for i in range(RoundManager.scores[0]):
		left_markers[i].visible = true
	for i in range(RoundManager.scores[1]):
		right_markers[i].visible = true

func show_round():
	if RoundManager.winner == -1:
		$Background/Round/Draw.visible = true
		$Background/Round/Text.visible = false
		$Background/Round/Number.visible = false
	
	# Fade in
	tween.interpolate_property($Background, "modulate", Color(1, 1, 1, 0),
		Color(1, 1, 1, 1), .5, Tween.TRANS_LINEAR, Tween.EASE_IN, .1)
	tween.start()
	yield(tween, "tween_completed")
	
	# Marker animation 
	var marker = null
	if RoundManager.winner == 0:
		marker = left_markers[RoundManager.scores[0] - 1]
	elif RoundManager.winner == 1:
		marker = right_markers[RoundManager.scores[1] - 1]
	
	$ScoreSFX.play()
	
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
		yield(tween, "tween_completed")
	
	if RoundManager.scores[0] < 3 and RoundManager.scores[1] < 3:
		display_timer.start()
		yield(display_timer, "timeout")
		emit_signal("finished")
		return
	
	# Winner label animation
	winner.rect_position = WINNER_POS[RoundManager.winner] - Vector2(0, 400)
	winner.visible = true
	tween.interpolate_property(winner, "rect_position", winner.rect_position,
		WINNER_POS[RoundManager.winner],
		.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	# Menu animation
	tween.interpolate_property($Background/Round/Restart, "rect_position",
			$Background/Round/Restart.rect_position, MENU_POS, .5,
			Tween.TRANS_BACK, Tween.EASE_OUT, .5)
	tween.interpolate_property($Background/Round/Quit, "rect_position",
			$Background/Round/Quit.rect_position, MENU_POS + Vector2(398, 0),
			.5, Tween.TRANS_BACK, Tween.EASE_OUT, .5)
	tween.start()
	yield(tween, "tween_completed")
	$Background/Round/Restart.disabled = false
	$Background/Round/Quit.disabled = false
	$Background/Round/Restart.grab_focus()
	
	RoundManager.scores = [0, 0]
	RoundManager.round_number = 1

func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Quit_pressed():
	get_tree().change_scene("res://main-menu/MainMenu.tscn")
