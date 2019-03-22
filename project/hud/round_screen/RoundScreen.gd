extends CanvasLayer

signal shown
signal hidden

onready var background = $Background
onready var button_restart = $Background/Buttons/Restart
onready var button_quit = $Background/Buttons/Quit
onready var buttons = $Background/Buttons
onready var display_timer = $DisplayTimer
onready var player_scores = $Background/ScoreGrid.get_children()
onready var round_number = $Background/Round/Number
onready var round_label = $Background/Round/Label
onready var tween = $Tween

const DELAY = .1
const DURATION = .5
const BACKGROUND_Y = -108
const BACKGROUND_OFFSCREEN_Y = -2000
const OFFSET_X = -96


func _ready():
	background.set_position(Vector2(OFFSET_X, BACKGROUND_OFFSCREEN_Y))
	
	button_restart.connect("pressed", self, "_on_Restart_pressed")
	button_quit.connect("pressed", self, "_on_Quit_pressed")

	for i in range(player_scores.size()):
		player_scores[i].visible = i < RoundManager.players_total


func show_round():
	var player_score = null
	
	round_number.text = str(RoundManager.round_number)
	
	# Check draw
	var is_draw = RoundManager.round_winner == -1
	round_label.text = "Draw" if is_draw else "Round"
	round_number.visible = not is_draw
	if not is_draw:
		player_score = player_scores[RoundManager.round_winner]
		RoundManager.round_number += 1
	
	for score in player_scores:
		score.crown.visible = score == player_score
	
	# Enter animation
	tween.interpolate_property(background, "rect_position:y", null,
			BACKGROUND_Y, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	emit_signal("shown")
	
	# Marker animation
	if not is_draw:
		player_score.marker_animation()
		yield(player_score, "marker_animation_ended")

	# Check win condition
	var match_winner = RoundManager.get_match_winner()
	if match_winner == -1:
		display_timer.start()
		yield(display_timer, "timeout")
		hide_round()
	else:
		win_animation(match_winner)


func hide_round():
	tween.interpolate_property(background, "rect_position:y", null,
			BACKGROUND_OFFSCREEN_Y, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	emit_signal("hidden")


func win_animation(match_winner):
	var button_pos = 880
	buttons.show()
	
	# Menu animation
	tween.interpolate_property(buttons, "rect_position:y", null, button_pos,
			DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_completed")

	button_quit.disabled = false
	button_restart.disabled = false
	button_restart.grab_focus()


func _on_Restart_pressed():
	RoundManager.reset_round()
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	get_tree().change_scene("res://main-menu/MainMenu.tscn")
