extends CanvasLayer

onready var tw = $Tween
onready var lower_jaw = $Jaw/Lower
onready var upper_jaw = $Jaw/Upper

signal finished

const KEYWORDS = ["current"]
const SCENES = {
	"ArenaMode": preload("res://gameplay/arena-mode/Arena.tscn"),
	"CharacterSelect": preload("res://menus/character-select/CharacterSelect.tscn"),
	"Credits": preload("res://menus/credits/Credits.tscn"),
	"MainMenu": preload("res://menus/main-menu/MainMenu.tscn"),
	"ModeSelect": preload("res://menus/mode-select/ModeSelect.tscn"),
	"OptionsMenu": preload("res://menus/options-menu/OptionsMenu.tscn"),
	"RaceMode": preload("res://gameplay/race-mode/Race.tscn")
}
const IN_DURATION = .5
const OUT_DELAY = .05
const OUT_DURATION = .5

var is_black_screen = false
var second_callback = false
var lower_final_y
var lower_initial_y
var upper_final_y
var upper_initial_y


func _ready():
	lower_final_y = -100
	lower_initial_y = $Jaw.rect_size.y
	upper_final_y = 0
	upper_initial_y = - upper_jaw.rect_size.y


# Scenes that want to start a transition to another scene should call this
# function for consistency. Scenes that want to be notified about transitions
# should join the "transition_sync" group and implement the relevant functions.
func transition_to(scene_name: String) -> void:
	if not scene_name in KEYWORDS and not scene_name in SCENES:
		return

	# Notify interested scenes just before the jaws close.
	get_tree().call_group("transition_sync", "_on_transition_in")
	_transition_in()
	yield(self, "finished")

	if scene_name in SCENES:
		get_tree().change_scene_to(SCENES[scene_name])

	else:
		match scene_name:
			"current":
				get_tree().reload_current_scene()

	_transition_out()
	yield(self, "finished")
	# Notify interested scenes just after the jaws open.
	get_tree().call_group("transition_sync", "_on_transition_out")


func _transition_in() -> void:
	$Jaw/Lower.rect_position.y = lower_initial_y
	$Jaw/Upper.rect_position.y = upper_initial_y
	
	tw.interpolate_property(lower_jaw, "rect_position:y", null, lower_final_y,
			IN_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tw.interpolate_property(upper_jaw, "rect_position:y", null, upper_final_y,
			IN_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tw.start()
	
	$CloseSFX.play()


func _transition_out() -> void:
	$Jaw/Lower.rect_position.y = upper_final_y
	$Jaw/Upper.rect_position.y = lower_final_y
	
	tw.interpolate_property(lower_jaw, "rect_position:y", null, lower_initial_y,
			IN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT, OUT_DELAY)
	tw.interpolate_property(upper_jaw, "rect_position:y", null, upper_initial_y,
			IN_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT, OUT_DELAY)
	tw.start()
	
	$OpenSFX.play()


func _on_Tween_tween_completed(object, key):
	# Only finishes the transition on the second time this function is called,
	# because of the two objects being tweened.
	if second_callback:
		emit_signal("finished")
		is_black_screen = !is_black_screen
	second_callback = !second_callback
