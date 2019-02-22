extends CanvasLayer

signal finished

onready var background = $Background
onready var button_restart = $Background/Buttons/Restart
onready var button_quit = $Background/Buttons/Quit
onready var buttons = $Background/Buttons
onready var display_timer = $DisplayTimer
onready var player_scores = $Background/ScoreGrid.get_children()
onready var round_draw = $Background/Round/Draw
onready var round_number = $Background/Round/Number
onready var round_text = $Background/Round/Text
onready var round_winner = $Background/Round/Winner
onready var tween = $Tween

const DELAY = .1
const DURATION = .5
const MENU_POS = Vector2(272, 550)
const ROUND_TEXTURES = [
		preload("res://hud/round_screen/ui_01.png"),
		preload("res://hud/round_screen/ui_02.png"),
		preload("res://hud/round_screen/ui_03.png"),
		preload("res://hud/round_screen/ui_04.png"),
		preload("res://hud/round_screen/ui_05.png")]
const WINNER_POS = [Vector2(50, 150), Vector2(980, 150)]

func _ready():
	background.modulate.a = 0
	round_number.texture = ROUND_TEXTURES[RoundManager.round_number - 1]
	
	button_restart.connect("pressed", self, "_on_Restart_pressed")
	button_quit.connect("pressed", self, "_on_Quit_pressed")

func show_round():
	var player_score = null

	# Check draw
	if RoundManager.winner == -1:
		round_draw.visible = true
		round_text.visible = false
		round_number.visible = false
	else:
		player_score = player_scores[RoundManager.winner]

	# Fade in
	tween.interpolate_property(background, "modulate:a", null, 1, DURATION,
			Tween.TRANS_LINEAR, Tween.EASE_IN, DELAY)
	tween.start()
	yield(tween, "tween_completed")

	# Marker animation
	if player_score:
		player_score.marker_animation()
		yield(player_score, "marker_animation_ended")

	# Check win condition
	if RoundManager.scores[0] < 3 and RoundManager.scores[1] < 3:
		display_timer.start()
		yield(display_timer, "timeout")
		emit_signal("finished")
	else:
		win_animation()

func hide_round():
	tween.interpolate_property(background, "modulate:a", 1, 0, DURATION,
			Tween.TRANS_LINEAR, Tween.EASE_IN, DELAY)
	tween.start()


func win_animation():
	# Winner label animation
	round_winner.rect_position = WINNER_POS[RoundManager.winner]
	round_winner.rect_scale = Vector2(2, 2)
	round_winner.modulate.a = 0
	round_winner.visible = true
	tween.interpolate_property(round_winner, "modulate:a", null, 1, DURATION,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(round_winner, "rect_scale", null, Vector2(1, 1),
			DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_completed")

	# Menu animation
	tween.interpolate_property(buttons, "rect_position", null, MENU_POS,
			DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_completed")

	button_quit.disabled = false
	button_restart.disabled = false
	button_restart.grab_focus()

	RoundManager.scores = [0, 0]
	RoundManager.round_number = 1


func _on_Restart_pressed():
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	get_tree().change_scene("res://main-menu/MainMenu.tscn")
