extends CanvasLayer

onready var tw = $Tween
onready var lower_jaw = $Jaw/Lower
onready var upper_jaw = $Jaw/Upper

signal finished

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


func transition_in():
	$Jaw/Lower.rect_position.y = lower_initial_y
	$Jaw/Upper.rect_position.y = upper_initial_y
	
	tw.interpolate_property(lower_jaw, "rect_position:y", null, lower_final_y,
			IN_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tw.interpolate_property(upper_jaw, "rect_position:y", null, upper_final_y,
			IN_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
	tw.start()
	
	$CloseSFX.play()


func transition_out():
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
