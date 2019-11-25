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

onready var char_sfx = {"jackie": $PirateWinSFX,
		"drill": $DrillWinSFX, "king": $KingWinSFX,
		"outsider": $GreenPirateWinSFX}

const TRIVIA = [
	"Great white sharks aren't so great after all",
	"There isn't always a bigger fish in the sea if you are a big-ass whale",
	"Hammerhead sharks eat nails",
	"Sharks always swim forwards because they are afraid of looking back into their past",
	"Sharks hunt fish without a fishing permit",
	"Sharks can see eletricity",
	"Whale sharks are not actually whales",
	"Goblin sharks are, indeed, goblins",
	"Cookiecutter sharks prefer icecream to cookies"
]

const DELAY = .1
const DURATION = .5
const BACKGROUND_Y = -108
const BACKGROUND_OFFSCREEN_Y = -2000
const OFFSET_X = -96

onready var _moved_up = false
onready var _moved_down = false
onready var _click_to_continue = false


func _ready():
	_click_to_continue = false
	set_process(true)
	background.set_position(Vector2(OFFSET_X, BACKGROUND_OFFSCREEN_Y))
	
	button_restart.connect("pressed", self, "_on_Restart_pressed")
	button_quit.connect("pressed", self, "_on_Quit_pressed")
	
	for i in range(player_scores.size()):
		player_scores[i].visible = i < RoundManager.players_total
	for i in range(RoundManager.players_total):
		set_player_sticker(i)


func _process(delta):
	if not _moved_up and Input.is_action_just_pressed("ui_joy_up"):
		_moved_up = true
		var cur_focus = $Background/Buttons.get_focus_owner()
		if cur_focus and cur_focus.focus_neighbour_top:
			cur_focus.get_node(cur_focus.focus_neighbour_top).grab_focus()
	if not _moved_down and Input.is_action_just_pressed("ui_joy_down"):
		_moved_down = true
		var cur_focus = $Background/Buttons.get_focus_owner()
		if cur_focus and cur_focus.focus_neighbour_bottom:
			cur_focus.get_node(cur_focus.focus_neighbour_bottom).grab_focus()
	if _moved_up and Input.is_action_just_released("ui_joy_up"):
		_moved_up = false
	if _moved_down and Input.is_action_just_released("ui_joy_down"):
		_moved_down = false

func _input(event):
	if (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_select")) and _click_to_continue:
		_click_to_continue = false
		hide_round()

func show_round():
	_click_to_continue = false
	var player_score = null
	
	round_number.text = str(RoundManager.round_number)
	
	# Check draw
	var is_draw = RoundManager.round_winner == -1
	round_label.text = "Draw" if is_draw else "Round"
	round_number.visible = not is_draw
	if not is_draw:
		player_score = player_scores[RoundManager.round_winner]
		RoundManager.round_number += 1
	
	# Win condition
	var match_winner = RoundManager.get_match_winner()
	if match_winner == -1:
		$Background/TriviaHeader.show()
		$Background/TriviaHeader.modulate.a = 1
		$Background/Trivia.show()
		$Background/Trivia.text = getRandomTrivia()
	else:
		var color = RoundManager.CHAR_COLOR[RoundManager.character_map[match_winner]]
		round_label.text = "Winner"
		round_number.text = str("P", match_winner + 1)
		round_number.modulate = color.lightened(.4)
		$Background/TriviaHeader.hide()
		$Background/Trivia.hide()
	
	for score in player_scores:
		score.crown.visible = score == player_score
	
	# Enter animation
	tween.interpolate_property(background, "rect_position:y", null,
			BACKGROUND_Y, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	$GateCloseSFX.play()
	
	yield(tween, "tween_completed")
	emit_signal("shown")
	
	# Marker animation
	if not is_draw:
		player_score.marker_animation()
		yield(player_score, "marker_animation_ended")

	# Hide condition
	if match_winner == -1:
		display_timer.start()
		yield(display_timer, "timeout")
		_click_to_continue = true
		
		$ContinueTimer.start()
		yield($ContinueTimer, "timeout")
		show_continue_text()
	else:
		win_animation(match_winner)


func show_continue_text():
	var fade_duration = .5
	
	tween.interpolate_property($Background/TriviaHeader, "modulate:a", 1, 0,
			fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property($Background/Trivia, "modulate:a", 1, 0,
			fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	yield(get_tree().create_timer(fade_duration), "timeout")
	$Background/Trivia.text = "Press START to continue"
	
	tween.interpolate_property($Background/Trivia, "modulate:a", 0, 1,
			fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func hide_round():
	$ContinueTimer.stop()
	
	tween.interpolate_property(background, "rect_position:y", null,
			BACKGROUND_OFFSCREEN_Y, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	$GateOpenSFX.play()
	
	yield(tween, "tween_completed")
	emit_signal("hidden")


func win_animation(match_winner):
	var button_pos = 880
	buttons.show()
	
	char_sfx[RoundManager.character_map[match_winner]].play()
	
	# BGM change
	Sound.fade_out(Sound.battle_bgm, $WinMatchBGM)
	
	# Menu animation
	tween.interpolate_property(buttons, "rect_position:y", null, button_pos,
			DURATION, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_completed")

	button_quit.disabled = false
	button_restart.disabled = false
	button_restart.grab_focus()


func transition():
	button_quit.disabled = true
	button_restart.disabled = true
	
	Transition.transition_in()


func set_player_sticker(index):
	var Sticker = get_node(str("Background/ScoreGrid/Player", index + 1, "/Portrait"))
	var PlayerNumber = get_node(str("Background/ScoreGrid/Player", index + 1, "/PlayerNumber"))
	var character = RoundManager.character_map[index]
	var char_sticker = load(str("res://assets/images/characters/", character, "/sticker.png"))
	var char_color = RoundManager.CHAR_COLOR[RoundManager.character_map[index]]
	
	PlayerNumber.set_modulate(char_color.lightened(.4))
	PlayerNumber.set_text(str("P", index + 1))
	Sticker.set_modulate(char_color.lightened(.4))
	Sticker.texture = char_sticker


func _on_Restart_pressed():
	RoundManager.reset_round()
	transition()
	yield(Transition, "finished")
	get_tree().reload_current_scene()


func _on_Quit_pressed():
	transition()
	Sound.stop_ambience()
	Sound.fade_out(Sound.battle_bgm, Sound.menu_bgm)
	yield(Transition, "finished")
	get_tree().change_scene("res://menus/mode-select/ModeSelect.tscn")


func getRandomTrivia():
	return TRIVIA[randi() % TRIVIA.size()]
